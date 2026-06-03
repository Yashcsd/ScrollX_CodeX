# scripts/generate_audio.py
import wave
import struct
import math
import os
import random

SR = 22050  # 22.05kHz mono is ideal for lightweight chiptune retro assets
OUTPUT_DIR = os.path.join("assets", "audio")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def save_wav(filename, samples):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SR)
        # Pack to 16-bit signed PCM
        packed = []
        for s in samples:
            val = max(-1.0, min(1.0, s))
            sample = int(val * 32767)
            packed.append(struct.pack('<h', sample))
        wav.writeframesraw(b"".join(packed))
    print(f"Generated {filename} ({len(samples)} samples, {len(samples)/SR:.2f}s)")

# ── Waveform Oscillators ──────────────────────────────────────────────────────
def osc_sine(phase):
    return math.sin(phase)

def osc_triangle(phase):
    p = phase / (2 * math.pi)
    return 2.0 * abs(2.0 * (p - math.floor(p + 0.5))) - 1.0

def osc_square(phase):
    return 0.3 if (phase % (2 * math.pi)) < math.pi else -0.3

def osc_noise():
    return random.uniform(-0.15, 0.15)

# ── Synthesis Helpers ─────────────────────────────────────────────────────────
def synth_note(freq, duration_sec, wave_type="sine", decay_rate=15):
    n = int(duration_sec * SR)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        decay = math.exp(-t * decay_rate)
        if wave_type == "sine":
            val = osc_sine(phase)
        elif wave_type == "triangle":
            val = osc_triangle(phase)
        elif wave_type == "square":
            val = osc_square(phase)
        else:
            val = osc_noise()
            
        phase += 2 * math.pi * freq / SR
        samples.append(val * decay)
    return samples

# ── SFX Synthesizers ──────────────────────────────────────────────────────────
def make_tap():
    # Crisp soft tap
    return synth_note(520, 0.06, "sine", decay_rate=60)

def make_swipe():
    # Frequency sweep (180Hz to 320Hz)
    n = int(0.12 * SR)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = 180 + 140 * (i / n)
        env = math.sin(math.pi * (i / n))  # arch envelope
        samples.append(osc_sine(phase) * env * 0.25)
        phase += 2 * math.pi * f / SR
    return samples

def make_pop():
    # Frequency sweep down
    n = int(0.06 * SR)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = 440 - 240 * (i / n)
        env = math.exp(-t * 60)
        samples.append(osc_sine(phase) * env * 0.35)
        phase += 2 * math.pi * f / SR
    return samples

def make_click():
    # High pitch click
    return synth_note(900, 0.02, "sine", decay_rate=150)

def make_coin():
    # Classic retro chime (C5 for 0.07s then E5 for 0.15s)
    chime = synth_note(523.25, 0.07, "sine", decay_rate=20)
    chime.extend(synth_note(659.25, 0.16, "sine", decay_rate=12))
    return chime

def make_success():
    # C-major arpeggio (C5 -> E5 -> G5 -> C6)
    arpeggio = []
    notes = [523.25, 659.25, 783.99, 1046.50]
    for freq in notes:
        arpeggio.extend(synth_note(freq, 0.09, "sine", decay_rate=16))
    # Tail
    arpeggio.extend(synth_note(notes[-1], 0.20, "sine", decay_rate=8))
    return arpeggio

def make_fail():
    # Dejected falling bass sweep (200Hz down to 100Hz)
    n = int(0.40 * SR)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = 200 - 100 * (i / n)
        env = math.exp(-t * 7)
        # Mix sine & triangle for warmth
        val = 0.6 * osc_sine(phase) + 0.4 * osc_triangle(phase)
        samples.append(val * env * 0.25)
        phase += 2 * math.pi * f / SR
    return samples

def make_tick():
    # Regular timer click
    return synth_note(750, 0.02, "sine", decay_rate=120)

def make_tension_tick():
    # Sharper, higher timer click
    return synth_note(1100, 0.03, "sine", decay_rate=100)

# ── Background Loops ──────────────────────────────────────────────────────────
def make_puzzle_loop():
    # Calm relaxing C-major/A-minor 12s loop (100 BPM)
    # 20 beats, 1 beat = 0.6s
    duration = 12.0
    n = int(duration * SR)
    samples = [0.0] * n
    
    # Bass chord notes (triangle)
    # Steps: Am (A2=110Hz), F (F2=87.3Hz), C (C3=130.8Hz), G (G2=98Hz)
    chords = [110.00, 87.31, 130.81, 98.00]
    beat_dur = 0.6
    
    for beat in range(20):
        chord_idx = (beat // 4) % 4
        # Bass pluck at start of bar or beat
        if beat % 2 == 0:
            pitch = chords[chord_idx]
            note_samples = synth_note(pitch, 1.2, "triangle", decay_rate=4)
            start_idx = int(beat * beat_dur * SR)
            for j, s in enumerate(note_samples):
                if start_idx + j < n:
                    samples[start_idx + j] += s * 0.12
                    
    # Ambient melody pluck (sine, echoing)
    # Pentatonic scale C5, D5, E5, G5, A5
    melody = [
        (0.0, 523.25), (0.6, 659.25), (1.2, 587.33), (2.4, 783.99),
        (3.0, 880.00), (3.6, 659.25), (4.2, 523.25), (4.8, 587.33),
        (6.0, 659.25), (6.6, 783.99), (7.2, 880.00), (8.4, 1046.50),
        (9.0, 783.99), (9.6, 659.25), (10.2, 587.33), (10.8, 523.25)
    ]
    for start_time, pitch in melody:
        note_samples = synth_note(pitch, 1.5, "sine", decay_rate=3.5)
        start_idx = int(start_time * SR)
        for j, s in enumerate(note_samples):
            if start_idx + j < n:
                samples[start_idx + j] += s * 0.08
                
    # Loop blending to avoid clipping at seams
    fade_len = int(0.2 * SR)
    for i in range(fade_len):
        fade_in = i / fade_len
        fade_out = 1.0 - fade_in
        samples[i] = samples[i] * fade_in + samples[n - fade_len + i] * fade_out
        
    return samples[:n - fade_len]

def make_arcade_loop():
    # Energetic, retro 8s loop (120 BPM)
    # 16 beats, 1 beat = 0.5s
    duration = 8.0
    n = int(duration * SR)
    samples = [0.0] * n
    beat_dur = 0.5
    
    # Active chiptune bassline (triangle)
    bass_prog = [110.0, 110.0, 130.8, 130.8, 98.0, 98.0, 87.3, 98.0] # A2, C3, G2, F2
    for step in range(32): # 8th notes
        step_time = step * 0.25
        pitch = bass_prog[(step // 4) % 8]
        # Arpeggiate octave on syncopated 8th notes
        if step % 2 == 1:
            pitch *= 2.0 # up an octave
            
        note_samples = synth_note(pitch, 0.22, "triangle", decay_rate=12)
        start_idx = int(step_time * SR)
        for j, s in enumerate(note_samples):
            if start_idx + j < n:
                samples[start_idx + j] += s * 0.08
                
    # Drum tracks (noise snare on 2/4, kick on 1/3)
    for beat in range(16):
        start_idx = int(beat * beat_dur * SR)
        if beat % 2 == 0: # Kick (sine pitch sweep)
            kick_n = int(0.12 * SR)
            phase = 0.0
            for j in range(kick_n):
                t = j / SR
                f = 120 - 80 * (j / kick_n)
                env = math.exp(-t * 22)
                if start_idx + j < n:
                    samples[start_idx + j] += osc_sine(phase) * env * 0.20
                phase += 2 * math.pi * f / SR
                
        if beat % 4 == 2 or beat % 4 == 0 and beat > 0: # Snare (noise burst)
            snare_n = int(0.08 * SR)
            for j in range(snare_n):
                t = j / SR
                env = math.exp(-t * 28)
                if start_idx + j < n:
                    samples[start_idx + j] += osc_noise() * env * 0.12
                    
    # Loop blending
    fade_len = int(0.15 * SR)
    for i in range(fade_len):
        fade_in = i / fade_len
        fade_out = 1.0 - fade_in
        samples[i] = samples[i] * fade_in + samples[n - fade_len + i] * fade_out
        
    return samples[:n - fade_len]

def make_quiz_loop():
    # Quiet, tension/focus ambient loop (12s, 90 BPM)
    duration = 12.0
    n = int(duration * SR)
    samples = [0.0] * n
    beat_dur = 0.667
    
    # Heartbeat low pulse (sine 60Hz) every 2 beats
    for beat in range(18):
        start_idx = int(beat * beat_dur * SR)
        if beat % 2 == 0:
            # lub-dub pulse
            pulses = [0, int(0.25 * SR)]
            for pulse_start in pulses:
                n_pulse = int(0.15 * SR)
                phase = 0.0
                for j in range(n_pulse):
                    t = j / SR
                    env = math.sin(math.pi * (j / n_pulse)) * 0.2
                    if start_idx + pulse_start + j < n:
                        samples[start_idx + pulse_start + j] += osc_sine(phase) * env * 0.25
                    phase += 2 * math.pi * 55 / SR
                    
        # Focus clock tick on every beat
        tick_samples = synth_note(700, 0.015, "sine", decay_rate=200)
        for j, s in enumerate(tick_samples):
            if start_idx + j < n:
                samples[start_idx + j] += s * 0.02
                
    # Ambient sparse notes (pentatonic bells)
    bells = [(2.0, 523.25), (4.5, 587.33), (8.0, 659.25), (10.5, 783.99)]
    for start_time, pitch in bells:
        bell_samples = synth_note(pitch, 2.0, "sine", decay_rate=3.0)
        start_idx = int(start_time * SR)
        for j, s in enumerate(bell_samples):
            if start_idx + j < n:
                samples[start_idx + j] += s * 0.05
                
    # Loop blending
    fade_len = int(0.2 * SR)
    for i in range(fade_len):
        fade_in = i / fade_len
        fade_out = 1.0 - fade_in
        samples[i] = samples[i] * fade_in + samples[n - fade_len + i] * fade_out
        
    return samples[:n - fade_len]

def make_reaction_loop():
    # Light space-arcade 8s loop (130 BPM)
    duration = 8.0
    n = int(duration * SR)
    samples = [0.0] * n
    step_dur = 60 / (130 * 4) # 16th note steps (0.115s)
    
    # Square wave arpeggios bouncing up and down
    pattern = [
        523.25, 587.33, 659.25, 783.99, 880.00, 783.99, 659.25, 587.33,
        587.33, 659.25, 783.99, 880.00, 1046.50, 880.00, 783.99, 659.25,
    ]
    
    for step in range(64):
        # Sparse trigger - only trigger on certain 16th steps to make it spacey
        if step % 2 == 0:
            pitch = pattern[step % 16]
            if (step // 8) % 2 == 1:
                pitch *= 1.2 # transposition shifts
            note_samples = synth_note(pitch, 0.15, "square", decay_rate=15)
            start_idx = int(step * step_dur * SR)
            for j, s in enumerate(note_samples):
                if start_idx + j < n:
                    samples[start_idx + j] += s * 0.05
                    
    # Add a slow low triangle swell underneath
    phase = 0.0
    for i in range(n):
        f = 110.0 + 20.0 * math.sin(2 * math.pi * i / n) # frequency sweep oscillation
        samples[i] += osc_triangle(phase) * 0.04
        phase += 2 * math.pi * f / SR
        
    # Loop blending
    fade_len = int(0.2 * SR)
    for i in range(fade_len):
        fade_in = i / fade_len
        fade_out = 1.0 - fade_in
        samples[i] = samples[i] * fade_in + samples[n - fade_len + i] * fade_out
        
    return samples[:n - fade_len]

# ── Execution ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Starting audio synthesis...")
    # SFX
    save_wav("tap.wav", make_tap())
    save_wav("swipe.wav", make_swipe())
    save_wav("pop.wav", make_pop())
    save_wav("click.wav", make_click())
    save_wav("coin.wav", make_coin())
    save_wav("success.wav", make_success())
    save_wav("fail.wav", make_fail())
    save_wav("tick.wav", make_tick())
    save_wav("tension_tick.wav", make_tension_tick())
    # BG loops
    save_wav("puzzle_loop.wav", make_puzzle_loop())
    save_wav("arcade_loop.wav", make_arcade_loop())
    save_wav("quiz_loop.wav", make_quiz_loop())
    save_wav("reaction_loop.wav", make_reaction_loop())
    print("Audio synthesis complete!")
