#include <opencv2/highgui/highgui.hpp>

namespace camera2flickr {
	const ::std::string WINDOW_NAME = "camera2flickr";
	const ::std::string DEFAULT_OUTPUT = "photo.jpg";
	const int DEFAULT_WAIT = 3;
	const int DEFAULT_WAITAFTER = 1;

	bool camera(const ::std::string& output = DEFAULT_OUTPUT, int wait = DEFAULT_WAIT, int waitafter = DEFAULT_WAITAFTER);
}