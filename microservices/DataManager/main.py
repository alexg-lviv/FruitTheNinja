from typing import Union

from fastapi import FastAPI,  HTTPException, Request
import torch
import os
import json
import csv
import pandas as pd
import random

from models import lstm

import warnings
warnings.filterwarnings("ignore")


app = FastAPI()


input_size = 10
hidden_size = 50
output_size = 2
num_layers = 1

model = lstm.LSTMModel(input_size, hidden_size, output_size, num_layers)
model.load_state_dict(torch.load("weights/lstm_0-1.pth"))
model.eval()
print("Model loaded.")


@app.post("/data_save")
async def data_save(request: Request):
    # Get the raw JSON data as a string
    raw_data = await request.body()
    
    json_data = json.loads(raw_data.decode("utf-8"))

    csv_filename = "data/output.csv"
    file_exists = os.path.exists(csv_filename) and os.path.getsize(csv_filename) > 0

    for frame in json_data:

        # Write JSON data as a row in the CSV file
        with open(csv_filename, mode="a", newline="", encoding="utf-8") as csv_file:
            row_dict = {}

            for obj in frame:
                for key, value in obj.items():
                    if key == "name":
                        continue

                    if type(value) in [dict, list, tuple]:
                        row_dict[key] = str(value)
                    else:
                        row_dict[key] = value

            
            csv_writer = csv.writer(csv_file)
            if not file_exists:
                file_exists = True
                csv_writer.writerow(row_dict.keys())
            csv_writer.writerow(row_dict.values())

    
    return json_data


@app.post("/post_endpoint")
async def post_endpoint(request: Request) -> int:
    # Get the raw JSON data as a string
    raw_data = await request.body()
    # return random.choice([0, 1])
    json_data = json.loads(raw_data.decode("utf-8"))

    df = None
    for frame in json_data:
        row_dict = {}

        for obj in frame:
            for key, value in obj.items():
                if key == "name":
                    continue

                row_dict[key] = value

        columns = list(row_dict.keys())
        if df is None:
            df = pd.DataFrame(columns=columns)
        df = pd.concat([df, pd.DataFrame([row_dict], columns=columns)], ignore_index=True)

    if df is None:
        return 0

    # ------
    for butt in ["b1", "b2", "b3", "b4"]:
        df[butt] = df["button_cooldown_times"].apply(lambda j: j[butt])

    general_needed = [
        "frame_count",
        "score",
        "combo",
        "is_combo_going",
        "time_left_seconds",
        "can_dash",
    ]

    buttons_needed = [
        "b1", "b2", "b3", "b4",
    ]

    df = df[general_needed + buttons_needed]
    df[general_needed] = df[general_needed].astype(int)

    # ------
    tensor_df = torch.FloatTensor(df.to_numpy()).unsqueeze(1)

    outputs = model(tensor_df)
    _, preds = torch.max(outputs, 1)

    mean_pred = torch.mean(preds, dtype=float)
    label = int(torch.round(mean_pred).item())

    print(f"Model predicted: [ {label} ]  with mean {mean_pred}")

    return label
