#!/usr/bin/env python3

import datetime
import os.path
import json

from datetime import datetime, timedelta
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/calendar.readonly"]


def main():
  """Shows basic usage of the Google Calendar API.
  Prints the start and name of the next 10 events on the user's calendar.
  """
  creds = None
  # The file token.json stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          "credentials.json", SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
      token.write(creds.to_json())

  try:
    service = build("calendar", "v3", credentials=creds)

    # Call the Calendar API
    now = datetime.utcnow()
    tomorrow = now + timedelta(hours=24)

    events_result = (
        service.events()
        .list(
            calendarId="primary",
            timeMin=now.isoformat() + "Z",  # 'Z' indicates UTC time
            timeMax=tomorrow.isoformat() + "Z",  # 'Z' indicates UTC time
            maxResults=10,
            singleEvents=True,
            orderBy="startTime",
        )
        .execute()
    )
    events = events_result.get("items", [])

    if not events:
      print('[{"start": "", "end": "", "summary": "No upcoming events found."}]')
      return

    # Prints the start and name of the next 10 events
    events = list(map(extract_event, events))
    print(json.dumps(events, ensure_ascii=False))

  except HttpError as error:
    print(f'[{{"start": "", "end": "", "summary": "An error occurred: {error}"}}]')

def extract_event(event):
  start = event["start"]["dateTime"]
  end = event["end"]["dateTime"]
  summary = event["summary"]
  description = event.get("description", "No description")

  # now = datetime.utcnow()
  start = datetime.strptime(start, "%Y-%m-%dT%H:%M:%SZ")
  end = datetime.strptime(end, "%Y-%m-%dT%H:%M:%SZ")

  return dict({
    "summary": summary,
    "description": description,
    "start": start.strftime("%H:%M"),
    "end": end.strftime("%H:%M")
  })

if __name__ == "__main__":
  main()
