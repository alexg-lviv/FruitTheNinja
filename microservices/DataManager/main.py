from typing import Union

from fastapi import FastAPI,  HTTPException, Request
import os
import json
import csv
import pandas as pd
import random

app = FastAPI()


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
    return random.choice([0, 1])
    
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
    
    
