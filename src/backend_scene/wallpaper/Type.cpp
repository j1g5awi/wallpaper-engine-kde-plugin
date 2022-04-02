#include "Type.hpp"

#include "Utils/Logging.h"

std::string wallpaper::ToString(const ImageType& type) {
#define IMG(str) \
    case ImageType::str: return #str;

    switch (type) {
        IMG(UNKNOWN);
        IMG(BMP);
        IMG(ICO);
        IMG(JPEG);
        IMG(JNG);
        IMG(PNG);
    default: LOG_ERROR("Not valied image type: %d", (int)type); return "";
    }
}

std::string wallpaper::ToString(const TextureFormat& format) {
#define Fmt(str) \
    case TextureFormat::str: return #str;

    switch (format) {
        Fmt(RGBA8);
        Fmt(BC1);
        Fmt(BC2);
        Fmt(BC3);
        Fmt(RGB8);
        Fmt(RG8);
        Fmt(R8);
    default: LOG_ERROR("Not valied tex format: %d", (int)format); return "";
    }
}
