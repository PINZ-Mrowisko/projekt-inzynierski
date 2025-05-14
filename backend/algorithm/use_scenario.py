from ortools.sat.python import cp_model

from backend.models.Constraints import Constraints
from backend.models.Tags import Tags
from backend.models.Worker import Worker


def setup_scenario():
    kasjer = Tags("kasjer", "ten co sprzedaje")
    wozek_widlowy = Tags("wózek widłowy", "z uprawnieniami na wózek widłowy")
    kierownik = Tags("kierownik", "pan i władca")
    koordynator = Tags("koordynator", "logistyka tego typu")

    tags = [kasjer, wozek_widlowy, kierownik, koordynator]

    cashier1 = Worker("Adam", "Mada", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier2 = Worker("Bartek", "Ketrab", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier3 = Worker("Czesław", "Wałsecz", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier4 = Worker("Alan", "Nala", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier5 = Worker("Barbara", "Arabrab", 20, "umowa zlecenie", 222, "123@wp.pl")
    cashier6 = Worker("Cecylia", "Ailycec", 20, "umowa zlecenie", 222, "123@wp.pl")

    cashier1.add_tag(kasjer)
    cashier2.add_tag(kasjer)
    cashier3.add_tag(kasjer)
    cashier4.add_tag(kasjer)
    cashier5.add_tag(kasjer)
    cashier6.add_tag(kasjer)

    wozkowy1 = Worker("Damian", "Naimad", 20, "umowa zlecenie", 222, "123@wp.pl")
    wozkowy2 = Worker("Duda", "Adud", 20, "umowa zlecenie", 222, "123@wp.pl")
    wozkowy3 = Worker("Dagmara", "Aramgad", 20, "umowa zlecenie", 222, "123@wp.pl")

    wozkowy1.add_tag(wozek_widlowy)
    wozkowy2.add_tag(wozek_widlowy)
    wozkowy3.add_tag(wozek_widlowy)

    manager1 = Worker("Edyta", "Atyde", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager1 = Worker("Eliasz", "Zsaile", 20, "umowa zlecenie", 222, "123@wp.pl")
    vice_manager2 = Worker("Edward", "Drawde", 20, "umowa zlecenie", 222, "123@wp.pl")

    manager1.add_tag(kierownik)
    vice_manager1.add_tag(kierownik)
    vice_manager2.add_tag(kierownik)

    coordinator1 = Worker("Felix", "Xilef", 20, "umowa zlecenie", 222, "123@wp.pl")
    coordinator2 = Worker("Fiona", "Anoif", 20, "umowa zlecenie", 222, "123@wp.pl")

    coordinator1.add_tag(koordynator)
    coordinator2.add_tag(koordynator)

    workers = [cashier1, cashier2, cashier3, cashier4, cashier5, cashier6,
               wozkowy1, wozkowy2, wozkowy3,
               manager1, vice_manager1, vice_manager2,
               coordinator1, coordinator2
               ]

    constraints = Constraints()

    return constraints, workers, tags