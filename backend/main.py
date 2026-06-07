from fastapi import FastAPI, UploadFile, File, Header, HTTPException, Depends
from psycopg2.extras import RealDictCursor
import psycopg2
from datetime import datetime, date, timezone, timedelta
import os, uuid, json

import anthropic
from birdnetlib import Recording
from birdnetlib.analyzer import Analyzer

analyzer = Analyzer()

# ── Biology + story context ────────────────────────────────────────────────

BIRD_BIO = {
    'Eurasian Blackbird': {
        'pl': 'Kos', 'sci': 'Turdus merula',
        'diet_pl': 'dżdżownice, jagody, owady',
        'breeding_pl': 'marzec–lipiec',
        'diet_en': 'earthworms, berries, insects',
        'breeding_en': 'March–July',
        'unique_pl': 'śpiewa jako pierwszy ptak o świcie; samiec ma jaskrawożółty dziób; alarm call ostrzega wszystkie ptaki w okolicy; chodzi po ziemi i dosłownie nasłuchuje dżdżownic pod powierzchnią',
        'unique_en': 'first bird to sing at dawn; male has bright yellow beak; alarm call warns all nearby birds; walks on ground and literally listens for earthworms underground',
    },
    'Common Starling': {
        'pl': 'Szpak', 'sci': 'Sturnus vulgaris',
        'diet_pl': 'owady, dżdżownice, owoce',
        'breeding_pl': 'kwiecień–czerwiec',
        'diet_en': 'insects, earthworms, fruit',
        'breeding_en': 'April–June',
        'unique_pl': 'jeden z najlepszych mimów ptasiego świata — potrafi naśladować inne gatunki, telefony i samochody; upierzenie połyskuje metalicznie zielono-fioletowo w słońcu; tworzy murmuracje liczące miliony osobników',
        'unique_en': 'one of the best avian mimics — can imitate other birds, phones and cars; plumage shimmers metallic green-purple in sunlight; forms murmurations of millions',
    },
    'Great Tit': {
        'pl': 'Sikora bogatka', 'sci': 'Parus major',
        'diet_pl': 'owady, nasiona, orzechy',
        'breeding_pl': 'kwiecień–czerwiec',
        'diet_en': 'insects, seeds, nuts',
        'breeding_en': 'April–June',
        'unique_pl': 'najagresywniejsza sikora w Europie; zimą chowa setki nasion i pamięta każdy schowek; ma kilkadziesiąt wariacji śpiewu; historycznie otwierała butelki mleka dziobem',
        'unique_en': 'most aggressive tit in Europe; caches hundreds of seeds and remembers every hiding spot; has dozens of song variations; historically opened milk bottles with its beak',
    },
    'Blue Tit': {
        'pl': 'Sikora modra', 'sci': 'Cyanistes caeruleus',
        'diet_pl': 'owady, nasiona, orzechy',
        'breeding_pl': 'kwiecień–czerwiec',
        'diet_en': 'insects, seeds, nuts',
        'breeding_en': 'April–June',
        'unique_pl': 'akrobata — zwisa głową w dół szukając owadów pod liśćmi; niebieska czapeczka odbija UV niewidoczne dla ludzi; zostaje z tobą przez cały rok, nie migruje',
        'unique_en': 'acrobat — hangs upside-down hunting insects under leaves; blue cap reflects UV invisible to humans; stays with you all year, does not migrate',
    },
    'European Robin': {
        'pl': 'Rudzik', 'sci': 'Erithacus rubecula',
        'diet_pl': 'owady, dżdżownice, jagody',
        'breeding_pl': 'marzec–lipiec',
        'diet_en': 'insects, earthworms, berries',
        'breeding_en': 'March–July',
        'unique_pl': 'chodzi za ogrodnikami kopiącymi ziemię i czeka na odsłonięte dżdżownice; śpiewa nocą pod latarniami; walczy z własnym odbiciem w lustrze; czerwona pierś to groźba dla rywali',
        'unique_en': 'follows gardeners digging soil and waits for exposed earthworms; sings at night under street lights; fights its own reflection; red breast is a threat display to rivals',
    },
    'House Sparrow': {
        'pl': 'Wróbel', 'sci': 'Passer domesticus',
        'diet_pl': 'nasiona, owady, resztki',
        'breeding_pl': 'kwiecień–sierpień',
        'diet_en': 'seeds, insects, scraps',
        'breeding_en': 'April–August',
        'unique_pl': 'kąpie się w piasku, nie w wodzie; jest z ludźmi od 10 000 lat — przyszedł z pierwszymi rolnikami; wróble w mieście szczebiotają inaczej niż wiejskie — adaptują pieśń do hałasu otoczenia',
        'unique_en': 'bathes in dust not water; has been with humans for 10,000 years since first farmers; urban sparrows chirp differently than rural ones — they adapt their song to ambient noise',
    },
    'Common Chaffinch': {
        'pl': 'Zięba', 'sci': 'Fringilla coelebs',
        'diet_pl': 'nasiona, owady',
        'breeding_pl': 'kwiecień–czerwiec',
        'diet_en': 'seeds, insects',
        'breeding_en': 'April–June',
        'unique_pl': 'samiec to jeden z najbarwniejszych ptaków ogrodu — różowy brzuch, niebieskawa głowa; śpiew ma regionalne dialekty jak ludzkie gwary; zimą przybywają do nas ziębice ze Skandynawii',
        'unique_en': 'male is one of the most colourful garden birds — pink breast, bluish head; song has regional dialects like human accents; female chaffinches from Scandinavia visit in winter',
    },
    'European Greenfinch': {
        'pl': 'Dzwoniec', 'sci': 'Chloris chloris',
        'diet_pl': 'nasiona, jagody',
        'breeding_pl': 'kwiecień–sierpień',
        'diet_en': 'seeds, berries',
        'breeding_en': 'April–August',
        'unique_pl': 'uwielbia nasiona słonecznika — może opróżnić karmnik w jeden ranek; populacja maleje przez epidemię trichomonezy; melodyjne "driu-driu" z czubka drzewa — to on',
        'unique_en': 'loves sunflower seeds — can empty a feeder in one morning; population declining due to trichomonosis; melodic "driu-driu" from tree top — that is this bird',
    },
    'Song Thrush': {
        'pl': 'Drozd śpiewak', 'sci': 'Turdus philomelos',
        'diet_pl': 'ślimaki, dżdżownice, jagody',
        'breeding_pl': 'marzec–lipiec',
        'diet_en': 'snails, earthworms, berries',
        'breeding_en': 'March–July',
        'unique_pl': 'jedyny ptak który tłucze ślimaki o kamień — ma swój ulubiony kamień "kowadełko"; powtarza każdą frazę śpiewu 2-3 razy; śpiewa nawet w deszczu',
        'unique_en': 'only bird to smash snails on a stone — has its favourite anvil rock; repeats each song phrase 2-3 times; sings even in the rain',
    },
}

_BLOCK_PL = ['Świt 5-8', 'Rano 8-11', 'Południe 11-14', 'Popołudnie 14-17', 'Wieczór 17-20']
_BLOCK_EN = ['Dawn 5-8', 'Morning 8-11', 'Midday 11-14', 'Afternoon 14-17', 'Evening 17-20']
_MONTH_PL = ['', 'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
             'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia']


def _hour_to_block(h: int) -> int:
    if 5  <= h < 8:  return 0
    if 8  <= h < 11: return 1
    if 11 <= h < 14: return 2
    if 14 <= h < 17: return 3
    if 17 <= h < 20: return 4
    return -1


def _generate_story(species_name: str, stats: dict) -> dict:
    bio   = BIRD_BIO.get(species_name, {})
    fav_h = stats.get('favorite_hour', 8)
    blk   = _hour_to_block(fav_h)
    first = stats.get('first_seen')

    first_pl = f"{first.day} {_MONTH_PL[first.month]} {first.year}" if first else "niedawno"
    first_en = first.strftime('%B %d, %Y') if first else "recently"
    blk_pl   = _BLOCK_PL[blk] if 0 <= blk <= 4 else f'o {fav_h}:00'
    blk_en   = _BLOCK_EN[blk] if 0 <= blk <= 4 else f'at {fav_h}:00'

    prompt = f"""Write a 2-3 sentence story card for a garden bird app.
Return ONLY valid JSON: {{"story_pl": "...", "story_en": "..."}}

RULE: The story MUST open with the surprising fact below — connect it to the user's timing data.
Do NOT mention: breeding season, food searching, regular visitor.

SURPRISING FACT about {bio.get('pl', species_name)}:
PL: {bio.get('unique_pl', species_name)}
EN: {bio.get('unique_en', species_name)}

USER DATA:
- Visits: {stats.get('visits', 0)}
- Favorite time: PL="{blk_pl}" / EN="{blk_en}"
- First seen: PL="{first_pl}" / EN="{first_en}"
- Days in garden: {stats.get('days_in_garden', 1)}
- Current month: {datetime.now().strftime('%B')}"""

    client = anthropic.Anthropic(api_key=os.environ.get('ANTHROPIC_API_KEY', ''))
    msg = client.messages.create(
        model='claude-haiku-4-5-20251001',
        max_tokens=300,
        messages=[{'role': 'user', 'content': prompt}],
    )

    raw = msg.content[0].text.strip()
    if '```' in raw:
        for part in raw.split('```'):
            part = part.strip().lstrip('json').strip()
            if part.startswith('{'):
                raw = part
                break

    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {'story_pl': raw[:250], 'story_en': raw[:250]}


# ── App setup ──────────────────────────────────────────────────────────────

app = FastAPI()

PHOTO_DIR = "/opt/bird-api/photos"
os.makedirs(PHOTO_DIR, exist_ok=True)

API_KEY = "bird-secret-2026-xK9mP"


def verify_key(x_api_key: str = Header(...)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")


def get_db():
    return psycopg2.connect(
        host="localhost", dbname="birddb", user="bird", password="bird123"
    )


def save_detection(species, confidence, det_type, audio_path=None):
    conn = get_db()
    cur  = conn.cursor()
    cur.execute(
        "INSERT INTO detections (timestamp, species, confidence, type, audio_path) "
        "VALUES (NOW(), %s, %s, %s, %s) RETURNING id",
        (species, confidence, det_type, audio_path),
    )
    det_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return det_id


# ── Health ─────────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "time": datetime.now().isoformat()}


# ── Audio (BirdNET) ────────────────────────────────────────────────────────

@app.post("/audio")
async def receive_audio(
    file: UploadFile = File(...), _: str = Depends(verify_key)
):
    tmp_path = f"/tmp/{uuid.uuid4()}.wav"
    with open(tmp_path, "wb") as f:
        f.write(await file.read())
    try:
        rec = Recording(
            analyzer, tmp_path,
            lat=52.0, lon=21.0,
            date=date.today(),
            min_conf=0.7,
        )
        rec.analyze()
        results = []
        for d in rec.detections:
            det_id = save_detection(
                d["common_name"], d["confidence"], "audio", audio_path=tmp_path
            )
            results.append({
                "id": det_id,
                "species": d["common_name"],
                "confidence": round(d["confidence"], 3),
            })

        # Zachowaj nagranie dla gatunku z najwyższym confidence
        if results:
            top     = max(results, key=lambda x: x["confidence"])
            sp_dir  = "/opt/bird-api/recordings/{}".format(
                top["species"].lower().replace(" ", "_")
            )
            os.makedirs(sp_dir, exist_ok=True)
            dest    = f"{sp_dir}/{uuid.uuid4()}.wav"
            os.rename(tmp_path, dest)

            # Zaktualizuj audio_path dla wszystkich detekcji z tego nagrania
            conn2 = get_db()
            cur2  = conn2.cursor()
            for r in results:
                cur2.execute(
                    "UPDATE detections SET audio_path = %s WHERE id = %s",
                    (dest, r["id"])
                )
            conn2.commit()
            cur2.close()
            conn2.close()
        else:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

        return {"detections": results, "count": len(results)}
    except Exception as e:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        raise e


# ── Snapshot (YOLOv8 — osobny serwis, coming soon) ─────────────────────────

@app.post("/snapshot")
async def receive_snapshot(
    file: UploadFile = File(...), _: str = Depends(verify_key)
):
    return {"status": "coming_soon", "note": "YOLOv8 will run as separate service"}


# ── Detections ─────────────────────────────────────────────────────────────

@app.get("/detections")
def get_detections(limit: int = 50, _: str = Depends(verify_key)):
    conn = get_db()
    cur  = conn.cursor()
    cur.execute(
        "SELECT id, timestamp, species, confidence, type "
        "FROM detections ORDER BY timestamp DESC LIMIT %s",
        (limit,),
    )
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [
        {
            "id": r[0],
            "timestamp": r[1].isoformat(),
            "species": r[2],
            "confidence": r[3],
            "type": r[4],
        }
        for r in rows
    ]


# ── Species list ───────────────────────────────────────────────────────────

@app.get("/species")
def get_species(_: str = Depends(verify_key)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                WITH visit_starts AS (
                    SELECT species, timestamp,
                        timestamp - LAG(timestamp)
                            OVER (PARTITION BY species ORDER BY timestamp) AS gap
                    FROM detections
                    WHERE species IS NOT NULL
                ),
                visits AS (
                    SELECT species, timestamp
                    FROM visit_starts
                    WHERE gap IS NULL OR gap > INTERVAL '15 minutes'
                ),
                hour_counts AS (
                    SELECT species,
                           EXTRACT(HOUR FROM timestamp)::int AS hour,
                           COUNT(*) AS cnt
                    FROM visits
                    GROUP BY species, EXTRACT(HOUR FROM timestamp)
                ),
                fav_hours AS (
                    SELECT DISTINCT ON (species)
                           species, hour AS favorite_hour
                    FROM hour_counts
                    ORDER BY species, cnt DESC
                )
                SELECT v.species,
                       COUNT(*)::int                          AS visits,
                       MAX(d.timestamp)                       AS last_seen,
                       MIN(d.timestamp)                       AS first_seen,
                       COUNT(DISTINCT d.timestamp::date)::int AS days_in_garden,
                       COALESCE(f.favorite_hour, 8)           AS favorite_hour
                FROM visits v
                JOIN detections d ON d.species = v.species
                LEFT JOIN fav_hours f ON f.species = v.species
                GROUP BY v.species, f.favorite_hour
                ORDER BY visits DESC
            """)
            return cur.fetchall()
    finally:
        conn.close()


# ── Species detail ─────────────────────────────────────────────────────────

@app.get("/species/{species_name}/story")
def get_species_story(
    species_name: str,
    lang: str = "pl",
    _: str = Depends(verify_key),
):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "SELECT story_pl, story_en, generated_at, visits_at_gen "
                "FROM species_info WHERE species = %s",
                (species_name,),
            )
            cached = cur.fetchone()

            cur.execute(
                "SELECT COUNT(*)::int AS visits FROM detections WHERE species = %s",
                (species_name,),
            )
            current_visits = cur.fetchone()["visits"]

            if cached and cached["generated_at"]:
                age_h = (datetime.now(timezone.utc) - cached["generated_at"]).total_seconds() / 3600
                visits_ok = current_visits <= (cached["visits_at_gen"] or 0) * 1.3
                if age_h < 24 and visits_ok:
                    story = cached.get(f"story_{lang}") or cached.get("story_pl", "")
                    return {
                        "story": story,
                        "generated_at": cached["generated_at"].isoformat(),
                        "cached": True,
                    }

            cur.execute("""
                SELECT COUNT(*)::int AS visits,
                       MAX(timestamp) AS last_seen,
                       MIN(timestamp) AS first_seen,
                       COUNT(DISTINCT timestamp::date)::int AS days_in_garden
                FROM detections WHERE species = %s
            """, (species_name,))
            stats = dict(cur.fetchone() or {})

            cur.execute("""
                SELECT EXTRACT(HOUR FROM timestamp)::int AS hour, COUNT(*) AS cnt
                FROM detections WHERE species = %s
                GROUP BY hour ORDER BY cnt DESC LIMIT 1
            """, (species_name,))
            fav = cur.fetchone()
            stats["favorite_hour"] = fav["hour"] if fav else 8
            stats["visits"] = current_visits

            try:
                stories  = _generate_story(species_name, stats)
                story_pl = stories.get("story_pl", "")
                story_en = stories.get("story_en", "")
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Generation failed: {e}")

            cur.execute("""
                INSERT INTO species_info
                    (species, story_pl, story_en, generated_at, visits_at_gen)
                VALUES (%s, %s, %s, NOW(), %s)
                ON CONFLICT (species) DO UPDATE SET
                    story_pl      = EXCLUDED.story_pl,
                    story_en      = EXCLUDED.story_en,
                    generated_at  = NOW(),
                    visits_at_gen = EXCLUDED.visits_at_gen
            """, (species_name, story_pl, story_en, current_visits))
            conn.commit()

            return {
                "story": story_pl if lang == "pl" else story_en,
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "cached": False,
            }
    finally:
        conn.close()


@app.get("/species/{species_name}")
def get_species_detail(species_name: str, _: str = Depends(verify_key)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT species,
                       COUNT(*)::int                          AS visits,
                       MAX(timestamp)                         AS last_seen,
                       MIN(timestamp)                         AS first_seen,
                       COUNT(DISTINCT timestamp::date)::int   AS days_in_garden
                FROM detections
                WHERE species = %s
                GROUP BY species
            """, (species_name,))
            stats = cur.fetchone()
            if not stats:
                raise HTTPException(status_code=404, detail="Species not found")

            cur.execute("""
                SELECT EXTRACT(HOUR FROM timestamp)::int AS hour, COUNT(*) AS cnt
                FROM detections WHERE species = %s
                GROUP BY hour ORDER BY cnt DESC LIMIT 1
            """, (species_name,))
            fav = cur.fetchone()
            stats["favorite_hour"] = fav["hour"] if fav else 8

            cur.execute("""
                SELECT EXTRACT(HOUR FROM timestamp)::int AS hour,
                       COUNT(*)::int AS cnt
                FROM detections WHERE species = %s
                GROUP BY hour ORDER BY hour
            """, (species_name,))
            histogram = {r["hour"]: r["cnt"] for r in cur.fetchall()}
            stats["hourly_histogram"] = [histogram.get(h, 0) for h in range(24)]

            return stats
    finally:
        conn.close()

# ── GET /activity/daily ────────────────────────────────────────────────────

@app.get("/activity/daily")
def get_daily_activity(days: int = 7, _: str = Depends(verify_key)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DATE(timestamp) AS day, COUNT(*)::int AS count
                FROM detections
                WHERE timestamp >= NOW() - (%s * INTERVAL '1 day')
                GROUP BY day
                ORDER BY day
            """, (days,))
            rows = {str(r["day"]): r["count"] for r in cur.fetchall()}

        # Wypełnij brakujące dni zerami
        result = []
        for i in range(days - 1, -1, -1):
            day = (datetime.now() - timedelta(days=i)).date()
            result.append({"date": str(day), "count": rows.get(str(day), 0)})
        return result
    finally:
        conn.close()


# ── GET /species/{name}/trend ──────────────────────────────────────────────

@app.get("/species/{species_name}/trend")
def get_species_trend(species_name: str, days: int = 7,
                      _: str = Depends(verify_key)):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DATE(timestamp) AS day, COUNT(*)::int AS count
                FROM detections
                WHERE species = %s
                    AND timestamp >= NOW() - (%s * INTERVAL '1 day')
                GROUP BY day
                ORDER BY day
            """, (species_name, days))
            rows = {str(r["day"]): r["count"] for r in cur.fetchall()}

        result = []
        for i in range(days - 1, -1, -1):
            day = (datetime.now() - timedelta(days=i)).date()
            result.append({"date": str(day), "count": rows.get(str(day), 0)})
        return result
    finally:
        conn.close()

# -- Species recording ------------------------
@app.get("/species/{species_name}/recordings")
def get_species_recordings(
    species_name: str,
    limit: int = 5,
    _: str = Depends(verify_key)
):
    conn = get_db()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, timestamp, confidence, audio_path
                FROM detections
                WHERE species = %s
                  AND audio_path IS NOT NULL
                ORDER BY timestamp DESC
                LIMIT %s
            """, (species_name, limit))
            rows = cur.fetchall()
            return [{
                'id':         r['id'],
                'timestamp':  r['timestamp'].isoformat(),
                'confidence': round(r['confidence'], 3),
                'url':        '/recordings/{}'.format(
                    r['audio_path'].replace(
                        '/opt/bird-api/recordings/', ''
                    )
                ),
            } for r in rows]
    finally:
        conn.close()
