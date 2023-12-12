from typing import Union

from fastapi import FastAPI,  HTTPException, Request
import os
import json
import csv

app = FastAPI()


@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.post("/post_endpoint")
async def post_endpoint(request: Request):
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
