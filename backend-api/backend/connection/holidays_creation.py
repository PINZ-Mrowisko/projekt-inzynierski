from datetime import date
import holidays

def get_holidays():

    current_year = date.today().year
    years = [current_year, current_year + 1] # chyba starczy na ten i rok do przodu

    pl_holidays = holidays.country_holidays("PL", years=years)
    holiday_list = []
    for d, name in pl_holidays.items():
        holiday_list.append({
            "date": d.isoformat(),
            "name": name,
        })
    return holiday_list