#include <cstdio>
#include <cstdlib>
#include <sstream>

#include "camera.h"

int main(int argc, char **argv)
{
	using namespace camera2flickr;

	const std::string output = argc < 2 ? DEFAULT_OUTPUT : argv[1];
	int wait = argc < 3 ? DEFAULT_WAIT : atol(argv[2]);
	int waitafter = argc < 4 ? DEFAULT_WAITAFTER : atol(argv[3]);
	bool result = camera(output, wait, waitafter);
	return result ? 0 : -1;
}
#ifndef _DEBUG
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	int argc;
	wchar_t** wargv;
	wargv = CommandLineToArgvW(GetCommandLine(), &argc);
	char** argv = new char*[argc];
	for (int i = 0; i < argc; ++i) {
		argv[i] = new char[256];
		wcstombs(argv[i], wargv[i], 256);
	}
	return main(argc, argv);
}
#endif
