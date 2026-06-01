// Audio SED MVP — Frontend logic
(function () {
  "use strict";

  const API = "";
  const RECORD_SECONDS = 5;
  const CLASS_COLORS = { Cough: "#EF4444", Breathing: "#3B82F6", Snoring: "#8B5CF6", Wheeze: "#F59E0B" };
  const modeSelect = document.getElementById("mode-select");

  const sampleList = document.getElementById("sample-list");
  const btnRecord = document.getElementById("btn-record");
  const recStatus = document.getElementById("rec-status");
  const resultsDiv = document.getElementById("results");
  const inferenceTime = document.getElementById("inference-time");
  const banner = document.getElementById("banner");
  const timelineSection = document.getElementById("timeline-section");
  const timeline = document.getElementById("timeline");
  const timelineLegend = document.getElementById("timeline-legend");
  const assessmentSection = document.getElementById("assessment-section");
  const assessmentForm = document.getElementById("assessment-form");
  const recommendationSection = document.getElementById("recommendation-section");

  let lastAnalysisResult = null;

  // --- Load samples ---
  async function loadSamples() {
    try {
      const res = await fetch(`${API}/api/samples`);
      const files = await res.json();
      sampleList.innerHTML = "";
      files.forEach((f) => {
        const li = document.createElement("li");
        li.className = "cursor-pointer hover:bg-blue-50 px-2 py-1 rounded transition";
        li.textContent = f;
        li.onclick = () => analyzeSample(f);
        sampleList.appendChild(li);
      });
      if (!files.length) sampleList.innerHTML = '<li class="text-gray-400">Không có mẫu</li>';
    } catch (e) {
      sampleList.innerHTML = '<li class="text-red-400">Lỗi tải danh sách</li>';
    }
  }

  // --- Analyze a sample file ---
  async function analyzeSample(filename) {
    showLoading();
    try {
      const res = await fetch(`${API}/api/samples/${filename}`);
      const blob = await res.blob();
      await sendForAnalysis(blob, filename);
    } catch (e) {
      showError("Lỗi phân tích: " + e.message);
    }
  }

  // --- Send blob to /api/analyze ---
  async function sendForAnalysis(blob, label) {
    const form = new FormData();
    form.append("file", blob, label || "recording.wav");
    const mode = modeSelect.value;
    const res = await fetch(`${API}/api/analyze?mode=${mode}`, { method: "POST", body: form });
    if (!res.ok) throw new Error(await res.text());
    const data = await res.json();
    renderResults(data);
  }

  // --- Recorder ---
  let recording = false;
  btnRecord.onclick = async () => {
    if (recording) return;
    recording = true;
    btnRecord.classList.add("recording");
    recStatus.textContent = "Đang thu...";

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream);
      const chunks = [];
      recorder.ondataavailable = (e) => chunks.push(e.data);
      recorder.onstop = async () => {
        stream.getTracks().forEach((t) => t.stop());
        const blob = new Blob(chunks, { type: "audio/webm" });
        showLoading();
        try {
          await sendForAnalysis(blob, "recording.webm");
        } catch (e) {
          showError("Lỗi: " + e.message);
        }
      };
      recorder.start();
      setTimeout(() => recorder.stop(), RECORD_SECONDS * 1000);
    } catch (e) {
      showError("Không thể truy cập microphone");
    } finally {
      setTimeout(() => {
        recording = false;
        btnRecord.classList.remove("recording");
        recStatus.textContent = "Nhấn để thu 5 giây";
      }, RECORD_SECONDS * 1000 + 200);
    }
  };

  // --- Render results ---
  function renderResults(data) {
    const { events, has_cough, inference_time_ms, duration_sec } = data;
    lastAnalysisResult = data;

    // Banner
    banner.classList.toggle("hidden", !has_cough);

    // Show assessment form if cough detected
    assessmentSection.classList.toggle("hidden", !has_cough);
    recommendationSection.classList.add("hidden");

    // Events list
    if (!events.length) {
      resultsDiv.innerHTML = '<p class="text-gray-500">Không phát hiện sự kiện hô hấp</p>';
    } else {
      resultsDiv.innerHTML = events
        .map(
          (e) =>
            `<div class="flex items-center gap-2 py-1 border-b border-gray-100">
              <span class="w-3 h-3 rounded-full inline-block" style="background:${CLASS_COLORS[e.class]}"></span>
              <span class="font-medium">${e.class_vi}</span>
              <span class="text-gray-400 ml-auto">${e.start.toFixed(1)}s–${e.end.toFixed(1)}s</span>
              <span class="text-xs text-gray-500">${(e.confidence * 100).toFixed(0)}%</span>
            </div>`
        )
        .join("");
    }

    inferenceTime.textContent = `⏱ ${inference_time_ms.toFixed(0)}ms | ${duration_sec}s audio`;

    // V2: Cough type classification
    const v2Box = document.getElementById("v2-result");
    if (data.cough_type_analysis) {
      const ct = data.cough_type_analysis;
      v2Box.classList.remove("hidden");
      v2Box.innerHTML = `
        <div class="flex items-center gap-3">
          <span class="text-2xl">${ct.cough_type === "dry" ? "🌵" : "💧"}</span>
          <div>
            <div class="font-bold text-lg">${ct.cough_type_vi}</div>
            <div class="text-xs text-gray-500">Confidence: ${(ct.confidence * 100).toFixed(0)}% | Ho khan: ${(ct.probabilities.dry * 100).toFixed(0)}% — Ho đờm: ${(ct.probabilities.wet * 100).toFixed(0)}%</div>
          </div>
        </div>`;
    } else {
      v2Box.classList.add("hidden");
      v2Box.innerHTML = "";
    }

    // Timeline
    if (events.length && duration_sec > 0) {
      timelineSection.classList.remove("hidden");
      timeline.innerHTML = "";
      events.forEach((e) => {
        const left = (e.start / duration_sec) * 100;
        const width = Math.max(((e.end - e.start) / duration_sec) * 100, 1);
        const bar = document.createElement("div");
        bar.className = "absolute top-1 bottom-1 rounded opacity-80";
        bar.style.left = left + "%";
        bar.style.width = width + "%";
        bar.style.background = CLASS_COLORS[e.class];
        bar.title = `${e.class_vi} (${e.start.toFixed(1)}s–${e.end.toFixed(1)}s)`;
        timeline.appendChild(bar);
      });
      // Legend
      const seen = new Set(events.map((e) => e.class));
      timelineLegend.innerHTML = [...seen]
        .map(
          (c) =>
            `<span class="flex items-center gap-1"><span class="w-3 h-3 rounded-full inline-block" style="background:${CLASS_COLORS[c]}"></span>${c}</span>`
        )
        .join("");
    } else {
      timelineSection.classList.add("hidden");
    }
  }

  // --- Assessment form submit ---
  assessmentForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = new FormData(assessmentForm);
    const coughEvents = lastAnalysisResult ? lastAnalysisResult.events.filter((ev) => ev.class === "Cough") : [];
    const maxConf = coughEvents.length ? Math.max(...coughEvents.map((ev) => ev.confidence)) : 0.5;

    const body = {
      cough_type: form.get("cough_type"),
      duration: form.get("duration"),
      subject: form.get("subject"),
      cough_frequency: form.get("cough_frequency"),
      red_flags: form.getAll("red_flags"),
      night_cough: form.get("night_cough") === "on",
      post_flu: form.get("post_flu") === "on",
      audio_has_cough: true,
      audio_cough_count: coughEvents.length,
      audio_confidence: maxConf,
    };

    try {
      const res = await fetch(`${API}/api/recommendation`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      if (!res.ok) throw new Error(await res.text());
      const data = await res.json();
      renderRecommendations(data);
    } catch (err) {
      alert("Lỗi: " + err.message);
    }
  });

  // --- Render recommendations ---
  function renderRecommendations(data) {
    recommendationSection.classList.remove("hidden");
    const { classification, recommendations, warnings, should_see_doctor } = data;

    // Warnings
    const warningsDiv = document.getElementById("warnings");
    if (warnings.length) {
      warningsDiv.innerHTML = warnings
        .map((w) => `<div class="bg-red-50 border border-red-200 text-red-700 rounded p-2 text-sm mb-2">⚠️ ${w}</div>`)
        .join("");
    } else {
      warningsDiv.innerHTML = "";
    }

    // Classification summary
    const summaryDiv = document.getElementById("classification-summary");
    summaryDiv.innerHTML = `
      <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
        <div><span class="text-gray-500">Loại ho:</span> <strong>${classification.cough_type_vi}</strong></div>
        <div><span class="text-gray-500">Thời gian:</span> <strong>${classification.duration_vi}</strong> <span class="text-xs text-gray-400">(${classification.duration_desc})</span></div>
        <div><span class="text-gray-500">Đối tượng:</span> <strong>${classification.subject_vi}</strong></div>
        <div><span class="text-gray-500">Mức độ:</span> <strong>${classification.severity}</strong></div>
      </div>
    `;

    // Recommendations
    const recsDiv = document.getElementById("recommendations");
    recsDiv.innerHTML = recommendations
      .map(
        (r) => `
        <div class="border rounded-lg p-3 ${r.category === "see_doctor" ? "border-red-300 bg-red-50" : "border-gray-200"}">
          <h3 class="font-semibold text-sm mb-1">${r.category_icon} ${r.category_label}</h3>
          <ul class="list-disc list-inside text-sm text-gray-700 space-y-0.5">
            ${r.items.map((item) => `<li>${item}</li>`).join("")}
          </ul>
        </div>`
      )
      .join("");

    // Scroll to recommendations
    recommendationSection.scrollIntoView({ behavior: "smooth" });
  }

  function showLoading() {
    resultsDiv.innerHTML = '<p class="text-blue-500 animate-pulse">Đang phân tích...</p>';
    inferenceTime.textContent = "";
  }

  function showError(msg) {
    resultsDiv.innerHTML = `<p class="text-red-500">${msg}</p>`;
    inferenceTime.textContent = "";
  }

  // Init
  loadSamples();
})();
