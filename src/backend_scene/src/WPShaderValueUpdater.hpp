#pragma once
#include "Interface/IShaderValueUpdater.h"
#include "Utils/MapSet.hpp"

#include <memory>
#include <vector>
#include <array>
#include <unordered_map>
#include <cstdint>
#include <chrono>
#include "SpriteAnimation.hpp"
#include "WPPuppet.hpp"
#include <Eigen/Dense>

namespace wallpaper
{

class Scene;

struct WPUniformInfo {
    bool has_MI { false };
    bool has_M { false };
    bool has_AM { false };
    bool has_MVP { false };
    bool has_MVPI { false };
    bool has_VP { false };

    bool has_BONES { false };
    bool has_TIME { false };
    bool has_DAYTIME { false };
    bool has_POINTERPOSITION { false };
    bool has_PARALLAXPOSITION { false };
    bool has_TEXELSIZE { false };
    bool has_TEXELSIZEHALF { false };
    bool has_SCREEN { false };
    bool has_LP { false };

    struct Tex {
        bool has_resolution { false };
        bool has_mipmap { false };
    };
    std::array<Tex, 12> texs;
};

struct WPShaderValueData {
    std::array<float, 2> parallaxDepth { 0.0f, 0.0f };
    // index + name
    std::vector<std::pair<int32_t, std::string>> renderTargets;

    std::vector<WPPuppet::AnimationLayer> puppet_layers;
    std::shared_ptr<WPPuppet>             puppet;
};

struct WPCameraParallax {
    bool  enable { false };
    float amount;
    float delay;
    float mouseinfluence;
};

class WPShaderValueUpdater : public IShaderValueUpdater {
public:
    WPShaderValueUpdater(Scene* scene): m_scene(scene) {}
    virtual ~WPShaderValueUpdater() {}

    void FrameBegin() override;

    void InitUniforms(SceneNode*, const ExistsUniformOp&) override;
    void UpdateUniforms(SceneNode*, sprite_map_t&, const UpdateUniformOp&) override;
    void FrameEnd() override;
    void MouseInput(double, double) override;
    void SetTexelSize(float x, float y) override;

    void SetNodeData(void*, const WPShaderValueData&);
    void SetCameraParallax(const WPCameraParallax& value) { m_parallax = value; }

    void SetScreenSize(uint16_t w, uint16_t h) override { m_screen_size = { (float)w, (float)h }; }

private:
    Scene*               m_scene;
    WPCameraParallax     m_parallax;
    double               m_dayTime { 0.0f };
    std::array<float, 2> m_texelSize { 1.0f / 1920.0f, 1.0f / 1080.0f };

    std::array<float, 2> m_mousePos { 0.5f, 0.5f };
    std::array<float, 2> m_mousePosInput { 0.5f, 0.5f };
    double               m_mouseDelayedTime { 0.0f };
    uint                 m_mouseInputCount { 0 };

    std::chrono::time_point<std::chrono::steady_clock> m_last_mouse_input_time;

    std::array<float, 2> m_screen_size { 1920, 1080 };

    Map<void*, WPShaderValueData> m_nodeDataMap;
    Map<void*, WPUniformInfo>     m_nodeUniformInfoMap;
};
} // namespace wallpaper
