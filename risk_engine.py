"""FloodGuard risk engine - PROTOTYPE (rule-based baseline, no external dependencies).

Pipeline: sensor + weather + satellite inputs -> risk score -> alert level -> SMS text
-> SHA-256 hash of the alert record (to be anchored on-chain via FloodRelief.anchorAlert).

Run:  python risk_engine/risk_engine.py
"""
import hashlib
import json
import time
from dataclasses import dataclass, asdict
from typing import Optional


@dataclass
class Reading:
    station: str
    river_level_m: float        # current water level
    danger_level_m: float       # official danger level for the station
    rise_rate_m_per_hr: float   # recent rate of rise
    rain_24h_mm: float          # forecast / observed rainfall
    soil_saturation: float      # 0..1 (from satellite / model)
    upstream_hazard: bool       # e.g. glacial-lake or landslide-dam alert upstream


def risk_score(r: Reading) -> float:
    """Weighted 0-100 score. Weights are placeholders to be calibrated on historical Nepal data."""
    level = min(r.river_level_m / r.danger_level_m, 1.5) / 1.5          # 0..1
    rise = min(max(r.rise_rate_m_per_hr, 0) / 1.0, 1.0)                 # 1 m/hr = max
    rain = min(r.rain_24h_mm / 200.0, 1.0)                              # 200 mm = max
    soil = max(0.0, min(r.soil_saturation, 1.0))
    score = 100 * (0.35 * level + 0.25 * rise + 0.20 * rain + 0.10 * soil)
    if r.upstream_hazard:
        score += 25
    return round(min(score, 100.0), 1)


def alert_level(score: float) -> str:
    if score >= 75:
        return "RED"
    if score >= 50:
        return "ORANGE"
    if score >= 30:
        return "YELLOW"
    return "GREEN"


MESSAGES = {
    "RED": ("DANGER: flood expected at {station}. Move to high ground NOW.",
            "खतरा: {station} मा बाढी आउने सम्भावना छ। तुरुन्तै उच्च स्थानमा जानुहोस्।"),
    "ORANGE": ("WARNING: flood risk rising at {station}. Prepare to evacuate.",
               "चेतावनी: {station} मा बाढीको जोखिम बढ्दैछ। निस्कन तयार हुनुहोस्।"),
    "YELLOW": ("WATCH: river levels rising at {station}. Stay alert.",
               "सतर्कता: {station} मा नदीको सतह बढ्दैछ। सतर्क रहनुहोस्।"),
}


def build_alert(r: Reading) -> Optional[dict]:
    score = risk_score(r)
    level = alert_level(score)
    if level == "GREEN":
        return None
    en, ne = MESSAGES[level]
    record = {
        "station": r.station, "level": level, "score": score,
        "sms_en": en.format(station=r.station), "sms_ne": ne.format(station=r.station),
        "timestamp": int(time.time()), "inputs": asdict(r),
    }
    # Canonical JSON -> SHA-256. This 32-byte hash is what gets anchored on-chain.
    canonical = json.dumps(record, sort_keys=True, ensure_ascii=False).encode()
    record["alert_hash"] = "0x" + hashlib.sha256(canonical).hexdigest()
    return record


def send_sms(record: dict) -> None:
    """Stub. Replace with an SMS / cell-broadcast gateway."""
    print(f"[SMS] ({record['level']}) {record['sms_en']}\n      {record['sms_ne']}")


def anchor_on_chain(record: dict) -> None:
    """Stub. Replace with a web3.py call: FloodRelief.anchorAlert(disasterId, alert_hash)."""
    print(f"[CHAIN] anchorAlert(hash={record['alert_hash']})")


if __name__ == "__main__":
    demo = [
        Reading("Bhote Koshi - Upstream", 4.1, 4.5, 0.8, 140, 0.9, True),
        Reading("Trishuli - Betrawati", 2.0, 4.0, 0.1, 40, 0.4, False),
        Reading("Trishuli - Nuwakot", 3.6, 4.0, 0.5, 120, 0.8, False),
    ]
    for reading in demo:
        alert = build_alert(reading)
        if alert is None:
            print(f"[OK] {reading.station}: GREEN (score {risk_score(reading)})")
            continue
        send_sms(alert)
        anchor_on_chain(alert)
