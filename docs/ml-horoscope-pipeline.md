# ML Horoscope Pipeline (HF -> Core ML -> AstroGlass)

## 1) Install Python deps

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install torch transformers coremltools sentencepiece
```

## 2) Download/convert model to Core ML

Example with TinyLlama:

```bash
python scripts/ml/convert_hf_to_coreml.py \
  --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --output AstroGlass/Resources/MLModels/TinyLlama.mlpackage \
  --max-seq-len 128
```

Alternative model id (if available in your HF account/local cache):

```bash
python scripts/ml/convert_hf_to_coreml.py \
  --model <YOUR_GPT2_HOROSCOPE_MODEL_ID> \
  --output AstroGlass/Resources/MLModels/GPT2Horoscope.mlpackage \
  --max-seq-len 128
```

## 3) Generate weekly forecasts JSON with the model

This generates 52 forecasts per language (`en`, `es`, `ca`, `fr`, `de`) and enforces work+money+love content.

```bash
python scripts/ml/generate_weekly_forecasts.py \
  --model TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --output-dir AstroGlass/Resources/WeeklyForecasts
```

## 4) Add `.mlpackage` to Xcode

- Drag `AstroGlass/Resources/MLModels/<model>.mlpackage` into the Xcode project.
- Ensure target membership includes `AstroGlass`.
- Build once so Xcode compiles it to `.mlmodelc`.

## 5) App behavior

The app currently reads weekly forecasts from:

- `AstroGlass/Resources/WeeklyForecasts/weekly_forecasts_en.json`
- `AstroGlass/Resources/WeeklyForecasts/weekly_forecasts_es.json`
- `AstroGlass/Resources/WeeklyForecasts/weekly_forecasts_ca.json`
- `AstroGlass/Resources/WeeklyForecasts/weekly_forecasts_fr.json`
- `AstroGlass/Resources/WeeklyForecasts/weekly_forecasts_de.json`

Each file uses:

```json
{ "forecasts": ["...52 entries..."] }
```

## Notes

- TinyLlama is large for mobile runtime generation; offline generation + JSON is safer for UX and battery.
- If you want fully on-device generation at runtime, add tokenizer + sampling in Swift over Core ML logits.
