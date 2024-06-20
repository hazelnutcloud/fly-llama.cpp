#!/bin/bash

/app/llama-server  --api-key $API_KEY -ngl 999 -mu $MODEL_URL -m "/models/$MODEL_FILE" --host "0.0.0.0"