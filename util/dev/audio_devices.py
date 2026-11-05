#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = ["sounddevice>=0.5"]
# ///
"""Print information about every audio device PortAudio knows about.

sounddevice is a thin ctypes/cffi wrapper around PortAudio, so this listing is
exactly what PortAudio sees - which is also what Csound sees by default.

Usage:
    uv run audio_devices.py           # human readable report
    uv run audio_devices.py --json    # same data as JSON
"""

from __future__ import annotations

import json
import sys

import sounddevice as sd

# PortAudio's PaHostApiTypeId, which sounddevice does not re-export.
HOST_API_TYPES = {
    0: "InDevelopment",
    1: "DirectSound",
    2: "MME",
    3: "ASIO",
    4: "SoundManager",
    5: "CoreAudio",
    7: "OSS",
    8: "ALSA",
    11: "WDMKS",
    12: "JACK",
    13: "WASAPI",
    14: "AudioScienceHPI",
    15: "AudioIO",
    16: "PulseAudio",
    17: "Sndio",
}


def host_api_type_name(index: int) -> str:
    """Read the host API type from the underlying PaHostApiInfo struct.

    sounddevice's query_hostapis() does not expose it. This reaches into
    sounddevice's private cffi handle, so fall back gracefully if that ever
    changes.
    """
    try:
        api_type = sd._lib.Pa_GetHostApiInfo(index).type
    except (AttributeError, TypeError):
        return "unknown"
    return HOST_API_TYPES.get(api_type, f"unknown({api_type})")


def fmt_seconds(value: float) -> str:
    """PortAudio reports -1 for latencies that do not apply to a direction."""
    return f"{value:.4f}" if value >= 0 else "-"


def collect() -> dict:
    """Gather host APIs and devices into plain Python objects."""
    default_in, default_out = sd.default.device

    hostapis = []
    for index, api in enumerate(sd.query_hostapis()):
        hostapis.append(
            {
                "index": index,
                "name": api["name"],
                "type": host_api_type_name(index),
                "device_count": len(api["devices"]),
                "default_input": api["default_input_device"],
                "default_output": api["default_output_device"],
            }
        )

    devices = []
    for index, dev in enumerate(sd.query_devices()):
        devices.append(
            {
                "index": index,
                "name": dev["name"],
                "hostapi_index": dev["hostapi"],
                "hostapi_name": hostapis[dev["hostapi"]]["name"],
                "max_input_channels": dev["max_input_channels"],
                "max_output_channels": dev["max_output_channels"],
                "default_samplerate": dev["default_samplerate"],
                "latency": {
                    "low_input": dev["default_low_input_latency"],
                    "low_output": dev["default_low_output_latency"],
                    "high_input": dev["default_high_input_latency"],
                    "high_output": dev["default_high_output_latency"],
                },
                "is_default_input": index == default_in,
                "is_default_output": index == default_out,
            }
        )

    return {
        "sounddevice": sd.__version__,
        "portaudio_version": sd.get_portaudio_version()[0],
        "portaudio_text": sd.get_portaudio_version()[1],
        "default_input": default_in,
        "default_output": default_out,
        "hostapis": hostapis,
        "devices": devices,
    }


def print_report(info: dict) -> None:
    def label(index: int) -> str:
        if index < 0:
            return "none"
        try:
            return f"[{index}] {sd.query_devices(index)['name']}"
        except sd.PortAudioError:
            return f"[{index}]"

    print(f"sounddevice {info['sounddevice']}")
    print(f"PortAudio {info['portaudio_text']} (version {info['portaudio_version']})")
    print(f"default input : {label(info['default_input'])}")
    print(f"default output: {label(info['default_output'])}")

    print(f"\nHost APIs ({len(info['hostapis'])})")
    for api in info["hostapis"]:
        print(
            f"  [{api['index']}] {api['name']} ({api['type']}) - "
            f"{api['device_count']} device(s), "
            f"default in {api['default_input']}, default out {api['default_output']}"
        )

    print(f"\nDevices ({len(info['devices'])})")
    for dev in info["devices"]:
        tags = ["default input"] * dev["is_default_input"]
        tags += ["default output"] * dev["is_default_output"]
        if dev["max_input_channels"] == 0 and dev["max_output_channels"] == 0:
            tags.append("no channels")
        suffix = f"   <-- {', '.join(tags)}" if tags else ""

        lat = dev["latency"]
        print(f"  [{dev['index']}] {dev['name']}{suffix}")
        print(f"      host API     : {dev['hostapi_name']} [{dev['hostapi_index']}]")
        print(
            f"      channels     : {dev['max_input_channels']} in, "
            f"{dev['max_output_channels']} out"
        )
        print(f"      default rate : {dev['default_samplerate']:g} Hz")
        print(
            "      latency      : "
            f"low {fmt_seconds(lat['low_input'])}/{fmt_seconds(lat['low_output'])} s, "
            f"high {fmt_seconds(lat['high_input'])}/{fmt_seconds(lat['high_output'])} s "
            "(in/out)"
        )


def main(argv: list[str]) -> int:
    as_json = False
    if argv:
        if argv[0] in ("-h", "--help"):
            print(__doc__)
            return 0
        if argv[0] == "--json":
            as_json = True
        else:
            print(f"unknown argument: {argv[0]}", file=sys.stderr)
            return 2

    try:
        info = collect()
    except sd.PortAudioError as exc:
        print(f"PortAudio error: {exc}", file=sys.stderr)
        return 1

    if as_json:
        json.dump(info, sys.stdout, indent=2)
        print()
    elif not info["devices"]:
        print("No audio devices found.")
    else:
        print_report(info)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
