from __future__ import annotations

import datetime

import cnlunar

from app.schemas import CompassDirection, HourBlock

SHICHEN_LABELS = [
    ("11:00 PM", "1:00 AM"),
    ("1:00 AM", "3:00 AM"),
    ("3:00 AM", "5:00 AM"),
    ("5:00 AM", "7:00 AM"),
    ("7:00 AM", "9:00 AM"),
    ("9:00 AM", "11:00 AM"),
    ("11:00 AM", "1:00 PM"),
    ("1:00 PM", "3:00 PM"),
    ("3:00 PM", "5:00 PM"),
    ("5:00 PM", "7:00 PM"),
    ("7:00 PM", "9:00 PM"),
    ("9:00 PM", "11:00 PM"),
]

DIRECTION_MAP = {
    "正北": ("N", "North"),
    "东北": ("NE", "Northeast"),
    "正东": ("E", "East"),
    "东南": ("SE", "Southeast"),
    "正南": ("S", "South"),
    "西南": ("SW", "Southwest"),
    "正西": ("W", "West"),
    "西北": ("NW", "Northwest"),
}


def compute_facts(target_date: datetime.date, hour: int = 10) -> dict:
    dt = datetime.datetime(target_date.year, target_date.month, target_date.day, hour, 0)
    lunar = cnlunar.Lunar(dt, godType="8char")

    lunar_date_str = f"{lunar.lunarMonthCn}{lunar.lunarDayCn}"
    if lunar.isLunarLeapMonth:
        lunar_date_str = f"闰{lunar_date_str}"

    solar_term = lunar.todaySolarTerms if lunar.todaySolarTerms != "无" else ""

    hour_blocks = _build_hour_blocks(lunar)
    compass_data = _build_compass(lunar)

    return {
        "date": target_date.isoformat(),
        "lunar_date": lunar_date_str,
        "lunar_date_cn": f"{lunar.lunarYearCn} {lunar.year8Char}[{lunar.chineseYearZodiac}]年 {lunar_date_str}",
        "solar_term": solar_term,
        "day_ganzhi": lunar.day8Char,
        "year_ganzhi": lunar.year8Char,
        "month_ganzhi": lunar.month8Char,
        "zodiac": lunar.chineseYearZodiac,
        "good_things": lunar.goodThing,
        "bad_things": lunar.badThing,
        "hour_blocks": [hb.model_dump() for hb in hour_blocks],
        "compass_data": compass_data,
        "level_name": lunar.todayLevelName,
        "good_god_names": lunar.goodGodName,
        "bad_god_names": lunar.badGodName,
        "zodiac_clash": lunar.chineseZodiacClash,
        "peng_taboo": lunar.get_pengTaboo(long=4, delimit=" / "),
        "day_officer": lunar.get_today12DayOfficer(),
        "five_elements": lunar.get_today5Elements(),
        "nayin": lunar.get_nayin(),
        "fetal_god": lunar.get_fetalGod(),
        "star28": lunar.get_the28Stars(),
    }


def _build_hour_blocks(lunar: cnlunar.Lunar) -> list[HourBlock]:
    ganzhi_list = lunar.twohour8CharList
    lucky_list = lunar.get_twohourLuckyList()
    blocks: list[HourBlock] = []

    for i, gz in enumerate(ganzhi_list):
        if i >= len(SHICHEN_LABELS):
            break
        start, end = SHICHEN_LABELS[i]
        lucky = lucky_list[i] if i < len(lucky_list) else ""
        blocks.append(HourBlock(start=start, end=end, ganzhi=gz, lucky=lucky))

    return blocks


def _build_compass(lunar: cnlunar.Lunar) -> dict:
    raw = lunar.get_luckyGodsDirection()
    result = {}
    if isinstance(raw, dict):
        for god_name, direction_cn in raw.items():
            if direction_cn in DIRECTION_MAP:
                code, eng = DIRECTION_MAP[direction_cn]
                result[god_name] = {"direction_cn": direction_cn, "direction": code, "label": eng}
    return result


def build_compass_directions(compass_data: dict) -> list[CompassDirection]:
    label_map = {
        "喜神": "Joy",
        "福神": "Blessing",
        "财神": "Wealth",
        "阳贵": "Noble Yang",
        "阴贵": "Noble Yin",
    }
    quality_map = {
        "喜神": "favorable",
        "福神": "favorable",
        "财神": "favorable",
        "阳贵": "steady",
        "阴贵": "steady",
    }
    directions: list[CompassDirection] = []
    for god_name, info in compass_data.items():
        label = label_map.get(god_name, god_name)
        quality = quality_map.get(god_name, "neutral")
        directions.append(
            CompassDirection(direction=info.get("direction", ""), label=label, quality=quality)
        )
    return directions
