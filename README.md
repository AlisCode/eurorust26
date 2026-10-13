# eurorust-2026-hackathon

Ever tried driving a car with a third person view?
No?
Well, this is your chance!

In this challenge, your team will be given a car which you can remote-control via simple HTTP requests.
However, this car doesn't have any sensors to know where it is!
Fortunately, you also have access to two cameras watching over the arena, and every car is fitted with an easily machine-recognisable ArUco marker.

With these tools at your disposal, your goal is to please the Helsing Oracle by driving your car to a quadrant of its choosing.
Keep your car in the right quadrant to maximise your score!

## Setup

To start off, connect to the Helsing hackathon Wi-Fi:

- SSID: `hs-hack`
- Password: provided by your friendly Helsingers

The team will also provide your car's IP and token, the camera IPs and tokens, and the viewer IP.
Use the provided IPs in place of the hostnames below if `.local` lookups are slow.

Don't hesitate to ask the team if you have any questions about the rest of the instructions.

## Driving your car

Each car has a number: you can find this on the reverse of the ArUco marker on top.
Supposing your marker is `N`, your car's control server will be running at `hackathon-N-car.local:5000`.

It's a simple HTTP server! The car is controlled by simply sending `PUT` requests to the root with a JSON body containing two fields:

0. `speed`, as a float between -1.0 (drive backwards) and 1.0 (drive forwards).
   Smaller values cause you to drive more slowly.
0. `flip`, as a boolean.
   If true, the wheels will drive in opposite directions, causing you to turn roughly in place.

You'll also need to send an `Authorization` header with a 6 digit authorization token - this will be provided by a friendly Helsinger, and is unique for each car.
Don't share it with other teams if you don't want to be sabotaged!

An example `curl` to drive car #9 forward at 50% speed might look like this:

```
curl -X PUT hackathon-9-car.local:5000 \
    --header "Content-Type: application/json" \
    --header "Authorization: 000000" \
    --data '{"speed":0.5,"flip":false}'
```

Things to note:

- There's a 100ms cool-down between requests.
- Any command to your car expires after 1 second (so you need to keep sending commands to keep it driving).
- `speed` values close to 0 may result in the motors not spinning as the torque is too low.

## Viewing the arena

In order to get a view of the arena, you can make a similar request to one of the two cameras.
All teams have access to both cameras, and you may want to use both to get the best view of the arena.

You'll still need a unique authorization token to access each camera.
The cameras are accessible on the network at:

- `hackathon-11-camera.local:50051/frame`
- `hackathon-12-camera.local:50051/frame`

An example `curl` might look like:

```
curl hackathon-11-camera.local:50051/frame --header "Authorization: 123456"
```

The response is a JPEG image of the last captured frame.
There is no rate limit on how often you may request a frame, but note that the cameras capture as fast as they can and cache the image - frequent requests may give the same frame.

All cars, and the corners of the arena, are equipped with an identifying ArUco marker in the `DICT_4X4_50` dictionary.
These markers are designed to be easily detectable for use in computer vision.
You will find libraries (such as OpenCV) out there that can detect the coordinates of these, along with the ID corresponding to a given marker, with minimal code required!  \
Feel free to challenge yourself and train your own models, but we'd recommend using an off-the-shelf model or library to get started.

## The Challenge

The arena is divided into four quadrants: **TL** (top-left), **TR** (top-right), **BR** (bottom-right), and **BL** (bottom-left).
At any given time, one quadrant is the **active goal**. Your job is to drive your car into the active quadrant and keep it there.

### Scoring

Your score is a **percentage accuracy** averaged over a rolling window of recent cycles.

- Each cycle lasts **20 seconds**, during which one quadrant is the active goal.
- During a cycle, the system tracks what fraction of time your car spends in the correct quadrant.
- Your displayed score is the **average accuracy** across the last **10 cycles** (0–100%).
- If the system **loses track** of your car (e.g. the marker is obscured), that time is not counted for or against you.

In the **10-minute final**, scores reset and measure the percentage of tracked time spent in the correct quadrant across the whole final. Highest score wins.

The active quadrant changes **every 20 seconds** to a randomly chosen different quadrant (the same quadrant is never picked twice in a row).

### Getting the current goal

Poll the camera viewer server to find out which quadrant is currently active:

```
curl http://<viewer-ip>:8000/goal
```

This returns a JSON response like:

```json
{"quadrant": "TR", "time_remaining": 14.3}
```

- `quadrant` — the currently active quadrant (`TL`, `TR`, `BR`, or `BL`).
- `time_remaining` — seconds until the next quadrant change.

No authorization is required. There's no rate limit, but polling once per second is more than sufficient.

### Watching the game

The camera viewer at `http://<viewer-ip>:8000` shows a live dashboard with:

- Both camera feeds with the active quadrant highlighted in green.
- A top-down arena map with quadrant overlay.
- A live scoreboard with countdown timer and per-car scores.
