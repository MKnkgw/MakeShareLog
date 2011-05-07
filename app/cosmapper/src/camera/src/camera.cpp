#include "camera.h"
#include <ctime>
#include <videoInput.h>
#include <opencv2/imgproc/imgproc_c.h>

const int PREVIEW_WIDTH = 640;
const int PREVIEW_HEIGHT = 480;

const int CAPTURE_WIDTH = 1600;
const int CAPTURE_HEIGHT = 1200;
const int CAPTURE_FPS = 10;

bool camera2flickr::camera(const ::std::string& output, int wait, int waitafter)
{
	cv::Point labelLoc(0, 0);
	CvFont labelFont;
	const double labelScale = 6.0;
	const int labelFontType = CV_FONT_HERSHEY_PLAIN;
	cvInitFont(&labelFont, CV_FONT_HERSHEY_PLAIN, labelScale, labelScale);
	const cv::Scalar labelColor = CV_RGB(255, 255, 255);
	int labelBaseline = 0;

	std::stringstream ss;

	//videoInput::setVerbose(false);

	videoInput VI;
	if (VI.listDevices() == 0)
		return false;

	VI.setupDevice(0, CAPTURE_WIDTH, CAPTURE_HEIGHT);

    VI.setIdealFramerate(0, CAPTURE_FPS);

    IplImage *preview = cvCreateImage(cvSize(PREVIEW_WIDTH, PREVIEW_HEIGHT), IPL_DEPTH_8U, 3);
    IplImage *photo = cvCreateImage(cvSize(CAPTURE_WIDTH, CAPTURE_HEIGHT), IPL_DEPTH_8U, 3);

	cv::namedWindow(WINDOW_NAME);

	cv::waitKey(1000);

	const clock_t start = clock();
	const clock_t end = start + wait * CLOCKS_PER_SEC;

	for (;;) {
		photo->imageData = reinterpret_cast<char*>(VI.getPixels(0, false, true));
		cvResize(photo, preview);

		const clock_t cur = clock();

		cv::waitKey(1);

		if (cur > end) {
			cv::imshow(WINDOW_NAME, preview);
			cv::imwrite(output, photo);
			cv::waitKey(waitafter*1000);
			break;
		} else {
			ss.clear();
			ss.str("");
			ss << 1 + (end - cur) / CLOCKS_PER_SEC;

			const std::string label = ss.str();

			const double w = PREVIEW_WIDTH;
			const double h = PREVIEW_HEIGHT;
			const cv::Size labelSize = cv::getTextSize(label, labelFontType, labelScale, 1, &labelBaseline);
			labelLoc.x = static_cast<int>((w - labelSize.width) / 2);
			labelLoc.y = static_cast<int>((h + labelSize.height) / 2);
			cvPutText(preview, label.c_str(), labelLoc, &labelFont, labelColor);
			cv::imshow(WINDOW_NAME, preview);
		}
	}
	cv::destroyWindow(WINDOW_NAME);
	return true;
}
