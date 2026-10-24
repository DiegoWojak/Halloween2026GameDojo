// Basado en "Glint" de shadecore_dev (godotshaders.com, CC0).
// Brillo diagonal que recorre el sprite. Sirve para cualquier Sprite2D/TextureRect:
// asignar Art/Shaders/Glint.tres como material.
shader_type canvas_item;

/* Glint texture. Any 1xN size texture can be used. */
uniform sampler2D gradient_texture;
/* Glint texture width in pixels. */
uniform float gradient_width : hint_range(0.0, 512.0, 1.0) = 32.0;

/* Manual. Se ignora si shine_speed > 0. */
uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
/* Pasadas por segundo (0 = usar shine_progress, p. ej. desde un AnimationPlayer). */
uniform float shine_speed : hint_range(0.0, 5.0, 0.01) = 0.5;
/* Pausa entre pasadas, en fracción de una pasada. */
uniform float shine_pause : hint_range(0.0, 10.0, 0.1) = 1.5;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 45.0;

/* Any pixels darker than this threshold will not receive glint. */
uniform float threshold : hint_range(0.0, 1.0) = 0.01;

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
    // COLOR ya trae textura * modulate; no se sobrescribe para respetar modulate.
    vec2 pixelation = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 pixelated_uv = floor(UV * pixelation) / pixelation;

    float t = shine_speed > 0.0 ? min(fract(TIME * shine_speed) * (1.0 + shine_pause), 1.0) : shine_progress;

    float slope = tan(radians(shine_angle));

    float progress = scale(t, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope + shine_size + shine_size * slope);

    float shine_distance = (slope * pixelated_uv.x - pixelated_uv.y - progress) / (sqrt(slope * slope + 1.0));

    float shine_color_coord = clamp((shine_distance / (2.0 * shine_size)) + 0.5, 0.0, 1.0);

    vec4 raw_color = texelFetch(gradient_texture, ivec2(int(shine_color_coord * (gradient_width - 1.0)), 0), 0);

    float shine = step(shine_distance, shine_size) - step(shine_distance, -shine_size);

    float max_component = max(max(COLOR.r, COLOR.g), COLOR.b);

    COLOR.rgb = mix(COLOR.rgb, raw_color.rgb, shine * raw_color.a * float(max_component >= threshold));
}
