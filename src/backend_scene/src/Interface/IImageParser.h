#pragma once
#include "Image.hpp"
//#include "Fs/VFS.h"
#include <memory>
#include <string>

namespace wallpaper
{
class IImageParser {
public:
    IImageParser()                                                 = default;
    virtual ~IImageParser()                                        = default;
    virtual std::shared_ptr<Image> Parse(const std::string&)       = 0;
    virtual ImageHeader            ParseHeader(const std::string&) = 0;
};
} // namespace wallpaper
