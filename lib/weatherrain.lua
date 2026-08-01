WeatherRain = {
    active = false,     -- está chovendo?
    intensity = 20,      -- 0–100 (chance de spawn)
    maxIntensity = 10,  -- intensidade máxima da chuva
    increaseRate = 2,   -- quanto aumenta por ciclo
    decreaseRate = 2,   -- quanto diminui por ciclo
    duration = 10,      -- duração da chuva forte (em ciclos)
    stage = "idle",     -- idle / starting / peak / ending
    timer = 0,
}
