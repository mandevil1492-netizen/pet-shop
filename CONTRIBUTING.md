# Katki Rehberi

Bu repo Godot 4.6 tabanli bir 3D petshop/veteriner oyunudur.

## Hizli Baslangic

1. Depoyu klonla.
2. Godot 4.6 ile `/Users/yanik/Documents/pet` klasorunu ac.
3. `scenes/menu.tscn` uzerinden oyunu calistir.

## Branch Akisi

1. `main` her zaman calisir durumda kalir.
2. Her yeni is icin yeni branch ac:
   - `feature/<kisa-aciklama>`
   - `fix/<kisa-aciklama>`
3. Degisiklikleri kucuk ve anlamli commit'lerle gonder.
4. Pull Request ac, en az bir kisi gozden gecirsin.
5. PR onaylandiktan sonra `main`e birlestir.

## Kod Kurallari

- GDScript'te acik isimlendirme kullan.
- Buyuk fonksiyonlar yerine kucuk, test edilebilir parcalar tercih et.
- Runtime sahne olusturmada null kontrolu ve hata logu ekle.
- Mevcut dosya yapisini koru:
  - `scenes/`
  - `scripts/`
  - `assets/`
  - `docs/`

## PR Kontrol Listesi

- [ ] Oyun Godot editorunde aciliyor.
- [ ] `Yeni Oyun` akisi parse/runtime hata vermiyor.
- [ ] Kayit/yukleme bozulmadi.
- [ ] Yeni eklenen UI elemanlari okunakli.
- [ ] README veya dokuman guncellendi (gerekiyorsa).

## Commit Mesaji Onerisi

- `feat: dis cevreye yeni yol seti eklendi`
- `fix: game_manager parse hatasi duzeltildi`
- `chore: docs ve template dosyalari guncellendi`
