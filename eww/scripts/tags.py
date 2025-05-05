#!/usr/bin/env python3

import json
import subprocess

# Define the "leftwm-state" command and start the process
cmd = ["leftwm-state"]
process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, text=True)

# Process the stream line by line
for line in process.stdout:
    try:
        # Parse each line as JSON
        state = json.loads(line)

        # Initialize an empty dictionary to store merged tags
        merged_tags = {}

        # Iterate through workspaces and tags
        for workspace in state["workspaces"]:
            for tag in workspace["tags"]:
                tag_name = tag["name"]
                if tag_name not in merged_tags:
                    merged_tags[tag_name] = {
                        "name": tag_name,
                        "busy": tag["busy"],
                        "workspace_index": ""
                    }
                if tag["mine"]:
                    merged_tags[tag_name]["workspace_index"] = workspace["index"]

        # Convert the merged_tags dictionary to a list
        merged_tags_list = list(merged_tags.values())

        # Convert the output_json to JSON format
        output_json_str = json.dumps(merged_tags_list)

        # Print the final JSON
        print(output_json_str, flush=True)

    except json.JSONDecodeError:
        # Handle invalid JSON lines, if any
        print(f"Skipping invalid JSON line: {line}")

# Close the process
process.stdout.close()
process.wait()
