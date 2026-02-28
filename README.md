# Pati Protokolu

3D petshop + veteriner temali yonetim oyunu prototipi (Godot 4.6).

## Kurulu uygulamalar

- `/Users/yanik/Applications/Godot.app`
- `/Users/yanik/Applications/Blender.app`
- `/Users/yanik/Applications/Visual Studio Code.app`

## Calistirma

1. Godot'u ac.
2. `Import` ile bu klasoru sec: `/Users/yanik/Documents/pet`
3. `Main Scene` olarak `res://scenes/menu.tscn` otomatik acilir.
4. `Play` ile menuden `Yeni Oyun` veya `Devam Et` sec.

## Bu prototipte ne var?

- 3 odali klinik akisi: resepsiyon -> muayene -> tedavi
- Calisan + hasta hareketli AI akisi
- Hasta kuyrugu, gunluk gider, gelir ve itibar dongusu
- Blender ile uretilmis ilk dusuk-poly asset paketi
- Oda yukseltme sistemi (resepsiyon, muayene, tedavi)
- Acil/normal vaka cesitliligi, streak ve bonus ekonomisi
- Serbest kamera kontrolu (mouse wheel + sag tik surukle + yon tuslari)
- Kritik vaka + sure baskisi (vaka fail sistemi)
- Acil Protokol secenegi
- Gunluk hedef sistemi ve skor ilerlemesi
- Rastgele gunluk olaylar (bonus/ceza)
- Kazanma/kaybetme kosullari
- Save/Load sistemi (JSON)
- Ana menu + ayarlar (fullscreen, kalite, ses)
- Yerel basarim takibi (4 temel basarim)
- Dis cevre dunya katmani (evler, yol agi, yuruyus yollari, agaclar, billboard)
- Ambient trafik ve yaya sistemi
- Gece-gunduz dongusu + dinamik dis/isik emisyonu
- Daha gercekci PBR materyal ve fiziksel gokyuzu

## Oynanis

1. `Yeni Hasta Cagir`
2. Hasta resepsiyona ve sonra muayene odasina gider
3. `Teshis Baslat`
4. Hasta tedavi odasina gecer
5. `Tedavi Uygula`
6. Hasta taburcu olur, yeni vaka icin tekrar `Yeni Hasta Cagir`
7. Acil/Kritik vakalarda gerekirse `Acil Protokol` kullan
8. Kazanc ile odalari yukselt, gunluk hedefi tamamla

## Kontroller

- Kamera zoom: Mouse wheel
- Kamera donus: Sag tik basili tutup surukle
- Kamera ince ayar: Yon tuslari
- Hizli kayit: F5
- Kayit yukle: F9
- Duraklat: P
- Ana menuye don: Esc

## Hedef

- Itibar >= 25
- Nakit >= $12000
- Klinik Skoru >= 3000

## Dosya Notlari

- Oyun mantigi: `/Users/yanik/Documents/pet/scripts/game_manager.gd`
- Kamera kontrolu: `/Users/yanik/Documents/pet/scripts/camera_controller.gd`
- Ana menu mantigi: `/Users/yanik/Documents/pet/scripts/menu_controller.gd`
- Global uygulama durumu: `/Users/yanik/Documents/pet/scripts/app_state.gd`
- Save dosyasi: `user://clinic_save.json`

## Asset paketi

- `/Users/yanik/Documents/pet/assets/models/counter.glb`
- `/Users/yanik/Documents/pet/assets/models/exam_table.glb`
- `/Users/yanik/Documents/pet/assets/models/shelf.glb`
- `/Users/yanik/Documents/pet/assets/models/medicine_cart.glb`
- `/Users/yanik/Documents/pet/assets/models/plant.glb`
- `/Users/yanik/Documents/pet/assets/models/chair.glb`
- `/Users/yanik/Documents/pet/assets/models/monitor.glb`
- `/Users/yanik/Documents/pet/assets/models/lamp.glb`
- `/Users/yanik/Documents/pet/assets/models/pet_cage.glb`
- `/Users/yanik/Documents/pet/assets/models/vet_character.glb`
- `/Users/yanik/Documents/pet/assets/models/pet_character.glb`
- Uretim scripti: `/Users/yanik/Documents/pet/tools/build_blender_assets.py`

## Sonraki odak

- Steam build/export ve depolama entegrasyonu
- Ses tasarimi (BGM/SFX paketleri)
- Animasyon kalitesi (rig + blend tree)
