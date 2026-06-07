// Audio SED MVP — FPT Long Châu Theme Frontend Logic
(function () {
  "use strict";

  const API = "";
  const RECORD_SECONDS = 5;
  const CLASS_COLORS = { 
    Cough: "#f37022",      // FPT Orange
    Breathing: "#00a651",  // Long Châu Green
    Snoring: "#9333ea",    // Purple
    Wheeze: "#eab308"      // Yellow
  };

  // DOM Elements
  const modeSelect = document.getElementById("mode-select");
  const modeBtnV1 = document.getElementById("mode-btn-v1");
  const modeBtnV2 = document.getElementById("mode-btn-v2");

  const sampleList = document.getElementById("sample-list");
  const btnRecord = document.getElementById("btn-record");
  const recStatus = document.getElementById("rec-status");
  const resultsDiv = document.getElementById("results");
  const inferenceTime = document.getElementById("inference-time");
  const banner = document.getElementById("banner");
  
  const canvas = document.getElementById("wave-canvas");
  const canvasCtx = canvas ? canvas.getContext("2d") : null;
  const wavePlaceholder = document.getElementById("wave-placeholder");

  const timelineSection = document.getElementById("timeline-section");
  const timeline = document.getElementById("timeline");
  const timelineLegend = document.getElementById("timeline-legend");
  
  const assessmentSection = document.getElementById("assessment-section");
  const assessmentForm = document.getElementById("assessment-form");
  const assessmentPlaceholder = document.getElementById("assessment-placeholder");
  
  const recommendationSection = document.getElementById("recommendation-section");
  const productsSection = document.getElementById("products-section");
  const productsList = document.getElementById("products-list");
  const outputColumn = document.getElementById("output-column");

  let lastAnalysisResult = null;
  let audioCtx = null;
  let analyser = null;
  let drawVisual = null;

  // --- Long Châu Mock Products Database ---
  const MOCK_PRODUCTS = {
    dry: [
      {
        name: "Viên ngậm thảo dược bổ phế Bảo Thanh",
        brand: "Hoa Linh (Việt Nam)",
        price: "36.000đ",
        unit: "Hộp 5 vỉ x 4 viên",
        image: `<svg class="w-7 h-7 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="5" stroke-dasharray="3" /></svg>`,
        desc: "Bổ phế, trừ ho khan, dịu họng, loãng đờm",
        tag: "Bán chạy nhất"
      },
      {
        name: "Siro ho thảo dược Prospan 100ml",
        brand: "Engelhard (Đức)",
        price: "82.000đ",
        unit: "Chai 100ml",
        image: `<svg class="w-7 h-7 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3h6m-5 3h4m-5 13v1a2 2 0 002 2h4a2 2 0 002-2v-1M7 6h10v10H7V6z" /></svg>`,
        desc: "Làm loãng dịch nhầy, dịu phế quản co thắt",
        tag: "Dược sĩ khuyên dùng"
      },
      {
        name: "Xịt họng sát khuẩn Keo Ong Propobee",
        brand: "DK Pharma (Việt Nam)",
        price: "115.000đ",
        unit: "Lọ 15ml",
        image: `<svg class="w-7 h-7 text-cyan-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M17 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V5a2 2 0 00-2-2zM9 7h6" /><path d="M12 3v-2M10 1h4" /></svg>`,
        desc: "Sát khuẩn tại chỗ, dịu nhanh cơn ho kích ứng",
        tag: "Công nghệ mới"
      }
    ],
    phlegm: [
      {
        name: "Siro ho trẻ em Prospan",
        brand: "Engelhard (Đức)",
        price: "82.000đ",
        unit: "Chai 100ml",
        image: `<svg class="w-7 h-7 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3h6m-5 3h4m-5 13v1a2 2 0 002 2h4a2 2 0 002-2v-1M7 6h10v10H7V6z" /></svg>`,
        desc: "Chiết xuất lá thường xuân hỗ trợ long đờm hiệu quả",
        tag: "Nhập khẩu Đức"
      },
      {
        name: "Viên sủi long đờm nhầy ACC200",
        brand: "Sandoz (Đức)",
        price: "68.000đ",
        unit: "Hộp 20 viên",
        image: `<svg class="w-7 h-7 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><rect x="5" y="7" width="14" height="14" rx="1" /><path d="M9 7V4M12 7V3M6 18L18 6" /></svg>`,
        desc: "Làm loãng đờm đặc trong các bệnh phế quản cấp & mạn",
        tag: "Người lớn khuyên dùng"
      },
      {
        name: "Dung dịch súc họng sát khuẩn Betadine 1%",
        brand: "Mundipharma (Thụy Sĩ)",
        price: "72.000đ",
        unit: "Chai 125ml",
        image: `<svg class="w-7 h-7 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M9 22h6M12 2v4M8 6h8v12H8z" /></svg>`,
        desc: "Diệt khuẩn hầu họng, ngăn ngừa nhiễm trùng thứ phát",
        tag: "Bác sĩ khuyên dùng"
      }
    ],
    allergic: [
      {
        name: "Thuốc chống dị ứng giảm kích ứng ngứa cổ Telfast 180mg",
        brand: "Sanofi (Pháp)",
        price: "90.000đ",
        unit: "Hộp 1 vỉ x 10 viên",
        image: `<svg class="w-7 h-7 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" /><path d="M9 3v18M15 3v18M3 9h18M3 15h18" /></svg>`,
        desc: "Kháng histamin thế hệ mới, giảm ngứa họng và ho dị ứng",
        tag: "Thương hiệu Pháp"
      },
      {
        name: "Viên sủi tăng sức đề kháng Redoxon Double Action",
        brand: "Bayer (Đức)",
        price: "75.000đ",
        unit: "Tuýp 10 viên",
        image: `<svg class="w-7 h-7 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><rect x="5" y="7" width="14" height="14" rx="1" /><path d="M9 7V4M12 7V3M6 18L18 6" /></svg>`,
        desc: "Bổ sung Vitamin C & Kẽm tăng miễn dịch đường hô hấp",
        tag: "Bảo vệ sức khỏe"
      }
    ],
    irritant: [
      {
        name: "Viên ngậm giảm ho ngứa rát họng Strepsils Cool",
        brand: "Reckitt (Anh)",
        price: "34.000đ",
        unit: "Hộp 2 vỉ x 12 viên",
        image: `<svg class="w-7 h-7 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="5" stroke-dasharray="3" /></svg>`,
        desc: "Giảm đau rát họng, giảm ho kích ứng do nhiệt độ, máy lạnh",
        tag: "Phổ biến"
      },
      {
        name: "Dung dịch xịt vệ sinh mũi họng nước muối biển sâu Xịt Spray",
        brand: "Pharmed (Việt Nam)",
        price: "45.000đ",
        unit: "Lọ 75ml",
        image: `<svg class="w-7 h-7 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z" /></svg>`,
        desc: "Rửa trôi khói bụi và các chất kích thích niêm mạc hô hấp",
        tag: "Khuyên dùng hàng ngày"
      }
    ],
    whooping: [
      {
        name: "Siro ho bổ phế Nam Hà Chỉ Khái Lộ",
        brand: "Dược Nam Hà (Việt Nam)",
        price: "32.000đ",
        unit: "Chai 125ml",
        image: `<svg class="w-7 h-7 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3h6m-5 3h4m-5 13v1a2 2 0 002 2h4a2 2 0 002-2v-1M7 6h10v10H7V6z" /></svg>`,
        desc: "Thảo dược trị ho lâu ngày, ho rít phế quản",
        tag: "Y học cổ truyền"
      }
    ]
  };

  // Draw static flatline on canvas startup
  function drawFlatLine() {
    if (!canvas || !canvasCtx) return;
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;
    canvasCtx.fillStyle = "rgb(15, 23, 42)"; // slate-900
    canvasCtx.fillRect(0, 0, canvas.width, canvas.height);
    canvasCtx.lineWidth = 1.5;
    canvasCtx.strokeStyle = "#475569"; // slate-600
    canvasCtx.beginPath();
    canvasCtx.moveTo(0, canvas.height / 2);
    canvasCtx.lineTo(canvas.width, canvas.height / 2);
    canvasCtx.stroke();
  }

  // Bind V1/V2 buttons to hidden select element
  if (modeBtnV1 && modeBtnV2 && modeSelect) {
    modeBtnV1.onclick = () => {
      modeSelect.value = "v1";
      modeBtnV1.className = "px-3 py-1.5 rounded-md font-semibold transition bg-white text-longchau-blue shadow-sm";
      modeBtnV2.className = "px-3 py-1.5 rounded-md font-semibold transition text-white hover:bg-white/10";
    };
    modeBtnV2.onclick = () => {
      modeSelect.value = "v2";
      modeBtnV2.className = "px-3 py-1.5 rounded-md font-semibold transition bg-white text-longchau-blue shadow-sm";
      modeBtnV1.className = "px-3 py-1.5 rounded-md font-semibold transition text-white hover:bg-white/10";
    };
  }

  // --- Help bind interactive choice cards to hidden inputs ---
  function setupInteractiveCards(groupId, hiddenInputName) {
    const container = document.getElementById(groupId);
    if (!container) return;
    const buttons = container.querySelectorAll("button");
    const hiddenInput = document.querySelector(`input[name="${hiddenInputName}"]`);

    buttons.forEach((btn) => {
      btn.addEventListener("click", () => {
        const val = btn.getAttribute("data-val");
        hiddenInput.value = val;
        
        buttons.forEach((b) => {
          b.classList.remove("step-active", "border-longchau-blue", "bg-longchau-blueLight");
        });
        btn.classList.add("step-active", "border-longchau-blue", "bg-longchau-blueLight");
      });
    });
  }

  // Initialize card bindings
  setupInteractiveCards("group-cough-type", "cough_type");
  setupInteractiveCards("group-duration", "duration");
  setupInteractiveCards("group-subject", "subject");
  setupInteractiveCards("group-severity", "cough_frequency");

  // --- Load samples ---
  async function loadSamples() {
    try {
      const res = await fetch(`${API}/api/samples`);
      const files = await res.json();
      sampleList.innerHTML = "";
      files.forEach((f) => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "px-3 py-1.5 bg-slate-50 hover:bg-longchau-blueLight hover:text-longchau-blue border border-gray-200 rounded-lg transition duration-200 font-medium text-gray-600 flex items-center gap-1.5";
        
        let icon = "🎵";
        if (f.includes("cough")) icon = "😷";
        else if (f.includes("breathing")) icon = "🫁";
        else if (f.includes("snoring")) icon = "💤";
        
        btn.innerHTML = `<span>${icon}</span> <span>${f}</span>`;
        btn.onclick = () => analyzeSample(f);
        sampleList.appendChild(btn);
      });
      if (!files.length) {
        sampleList.innerHTML = '<span class="text-gray-400">Không có mẫu âm thanh trong hệ thống</span>';
      }
    } catch (e) {
      sampleList.innerHTML = '<span class="text-red-500 font-semibold">⚠️ Lỗi tải danh sách mẫu âm thanh từ máy chủ</span>';
    }
  }

  // --- Auto-detect subject from sample filename ---
  function detectSubjectFromFilename(filename) {
    const lower = filename.toLowerCase();
    if (lower.includes("child") || lower.includes("tre_em") || lower.includes("baby")) return "child";
    if (lower.includes("infant") || lower.includes("so_sinh")) return "infant";
    return null;
  }

  function selectSubject(value) {
    const hiddenInput = document.querySelector('input[name="subject"]');
    if (hiddenInput) hiddenInput.value = value;
    const container = document.getElementById("group-subject");
    if (!container) return;
    container.querySelectorAll("button").forEach(btn => {
      if (btn.getAttribute("data-val") === value) {
        btn.classList.add("step-active", "border-longchau-blue", "bg-longchau-blueLight");
      } else {
        btn.classList.remove("step-active", "border-longchau-blue", "bg-longchau-blueLight");
      }
    });
  }

  // --- Analyze a sample file ---
  async function analyzeSample(filename) {
    showLoading();
    // Auto-select subject based on filename
    const detectedSubject = detectSubjectFromFilename(filename);
    if (detectedSubject) {
      selectSubject(detectedSubject);
    } else {
      selectSubject("adult");
    }
    try {
      const res = await fetch(`${API}/api/samples/${filename}`);
      const blob = await res.blob();
      await sendForAnalysis(blob, filename);
    } catch (e) {
      showError("Lỗi phân tích tệp mẫu: " + e.message);
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
    btnRecord.classList.add("recording-pulse");
    recStatus.textContent = "Đang thu âm...";

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const recorder = new MediaRecorder(stream);
      const chunks = [];

      // Web Audio Visualizer Setup
      audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const source = audioCtx.createMediaStreamSource(stream);
      analyser = audioCtx.createAnalyser();
      analyser.fftSize = 256;
      const bufferLength = analyser.frequencyBinCount;
      const dataArray = new Uint8Array(bufferLength);
      source.connect(analyser);

      if (wavePlaceholder) wavePlaceholder.classList.add("hidden");
      canvas.width = canvas.clientWidth;
      canvas.height = canvas.clientHeight;

      function draw() {
        if (!recording) return;
        drawVisual = requestAnimationFrame(draw);
        analyser.getByteTimeDomainData(dataArray);

        canvasCtx.fillStyle = "rgb(15, 23, 42)";
        canvasCtx.fillRect(0, 0, canvas.width, canvas.height);
        canvasCtx.lineWidth = 3;

        // Draw nice color gradient line representing FPT Long Châu brand palette
        const gradient = canvasCtx.createLinearGradient(0, 0, canvas.width, 0);
        gradient.addColorStop(0, "#02509b"); // Long Châu Blue
        gradient.addColorStop(0.5, "#f37022"); // FPT Orange
        gradient.addColorStop(1, "#00a651"); // Green
        canvasCtx.strokeStyle = gradient;

        canvasCtx.beginPath();
        const sliceWidth = (canvas.width * 1.0) / bufferLength;
        let x = 0;

        for (let i = 0; i < bufferLength; i++) {
          const v = dataArray[i] / 128.0;
          const y = (v * canvas.height) / 2;
          if (i === 0) {
            canvasCtx.moveTo(x, y);
          } else {
            canvasCtx.lineTo(x, y);
          }
          x += sliceWidth;
        }

        canvasCtx.lineTo(canvas.width, canvas.height / 2);
        canvasCtx.stroke();
      }

      draw();

      // Start Recording
      recorder.ondataavailable = (e) => chunks.push(e.data);
      recorder.onstop = async () => {
        stream.getTracks().forEach((t) => t.stop());
        
        // Clean audio visualizer contexts
        if (audioCtx) {
          audioCtx.close();
        }
        cancelAnimationFrame(drawVisual);
        drawFlatLine();
        
        if (wavePlaceholder) {
          wavePlaceholder.classList.remove("hidden");
          wavePlaceholder.textContent = "Nhấn REC để thu âm tiếp";
        }

        const blob = new Blob(chunks, { type: "audio/webm" });
        showLoading();
        try {
          await sendForAnalysis(blob, "recording.webm");
        } catch (e) {
          showError("Lỗi chẩn đoán: " + e.message);
        }
      };
      
      recorder.start();
      setTimeout(() => recorder.stop(), RECORD_SECONDS * 1000);
    } catch (e) {
      showError("Không thể truy cập microphone của thiết bị. Hãy cấp quyền truy cập mic.");
      recording = false;
      btnRecord.classList.remove("recording-pulse");
      recStatus.textContent = "Nhấn để thu âm 5 giây";
    } finally {
      setTimeout(() => {
        recording = false;
        btnRecord.classList.remove("recording-pulse");
        recStatus.textContent = "Nhấn để thu âm 5 giây";
      }, RECORD_SECONDS * 1000 + 200);
    }
  };

  // --- Render results ---
  function renderResults(data) {
    const { events, has_cough, inference_time_ms, duration_sec } = data;
    lastAnalysisResult = data;

    // Show/hide consulting banner
    if (banner) {
      banner.classList.toggle("hidden", !has_cough);
    }

    // Toggle assessment section & hide recommendations
    if (assessmentSection) {
      assessmentSection.classList.toggle("hidden", !has_cough);
      assessmentSection.classList.remove("xl:col-span-5");
      assessmentSection.classList.add("xl:col-span-9");
    }
    if (assessmentPlaceholder) {
      assessmentPlaceholder.classList.toggle("hidden", has_cough);
    }
    if (outputColumn) {
      outputColumn.classList.add("hidden");
    }
    if (recommendationSection) {
      recommendationSection.classList.add("hidden");
    }
    if (productsSection) {
      productsSection.classList.add("hidden");
    }

    // Events summary rendering
    if (!events.length) {
      resultsDiv.innerHTML = `
        <div class="bg-slate-50 border border-gray-100 rounded-xl p-4 text-center text-xs text-gray-500 font-medium">
          💨 Không phát hiện âm thanh hô hấp bất thường (ho, rít, thở dốc).
        </div>`;
    } else {
      resultsDiv.innerHTML = events
        .map(
          (e) =>
            `<div class="flex items-center gap-2 py-2.5 border-b border-gray-100 text-xs">
              <span class="w-3.5 h-3.5 rounded-full inline-block flex-shrink-0" style="background:${CLASS_COLORS[e.class] || '#6b7280'}"></span>
              <div>
                <span class="font-bold text-gray-800">${e.class_vi}</span>
                <span class="text-gray-400 text-[10px] ml-1.5">${e.start.toFixed(1)}s – ${e.end.toFixed(1)}s</span>
              </div>
              <span class="text-xs font-extrabold ml-auto" style="color:${CLASS_COLORS[e.class] || '#6b7280'}">${(e.confidence * 100).toFixed(0)}%</span>
            </div>`
        )
        .join("");
    }

    if (inferenceTime) {
      inferenceTime.textContent = `⏱️ ${inference_time_ms.toFixed(0)}ms | ${duration_sec}s audio`;
    }

    // V2: Cough type classification (Dry vs Wet)
    const v2Box = document.getElementById("v2-result");
    if (data.cough_type_analysis) {
      const ct = data.cough_type_analysis;
      v2Box.classList.remove("hidden");
      
      const dryPct = (ct.probabilities.dry * 100).toFixed(0);
      const wetPct = (ct.probabilities.wet * 100).toFixed(0);

      // Autofill dry/wet selection in the form based on AI
      const hiddenCoughType = document.querySelector('input[name="cough_type"]');
      if (hiddenCoughType) {
        hiddenCoughType.value = ct.cough_type;
        // Update selection UI to match
        const typeContainer = document.getElementById("group-cough-type");
        if (typeContainer) {
          typeContainer.querySelectorAll("button").forEach(btn => {
            if (btn.getAttribute("data-val") === ct.cough_type) {
              btn.classList.add("step-active", "border-longchau-blue", "bg-longchau-blueLight");
            } else {
              btn.classList.remove("step-active", "border-longchau-blue", "bg-longchau-blueLight");
            }
          });
        }
      }

      v2Box.innerHTML = `
        <div class="space-y-3">
          <div class="flex items-center gap-3">
            <span class="text-3xl">${ct.cough_type === "dry" ? "🌵" : "💧"}</span>
            <div>
              <div class="font-bold text-gray-800 text-sm">Chẩn đoán ho: <span class="text-longchau-blue">${ct.cough_type_vi}</span></div>
              <div class="text-[10px] text-gray-500 font-medium">Độ chính xác AI: ${(ct.confidence * 100).toFixed(0)}%</div>
            </div>
          </div>
          
          <div class="space-y-1.5 pt-1">
            <div>
              <div class="flex justify-between text-[10px] font-bold text-gray-600 mb-0.5">
                <span>Ho khan</span>
                <span>${dryPct}%</span>
              </div>
              <div class="w-full bg-slate-100 rounded-full h-1.5 overflow-hidden">
                <div class="bg-longchau-orange h-1.5 rounded-full" style="width: ${dryPct}%"></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between text-[10px] font-bold text-gray-600 mb-0.5">
                <span>Ho có đờm</span>
                <span>${wetPct}%</span>
              </div>
              <div class="w-full bg-slate-100 rounded-full h-1.5 overflow-hidden">
                <div class="bg-longchau-blue h-1.5 rounded-full" style="width: ${wetPct}%"></div>
              </div>
            </div>
          </div>
        </div>`;
    } else {
      v2Box.classList.add("hidden");
      v2Box.innerHTML = "";
    }

    // Timeline Rendering
    if (events.length && duration_sec > 0 && timeline && timelineSection) {
      timelineSection.classList.remove("hidden");
      timeline.innerHTML = "";
      events.forEach((e) => {
        const left = (e.start / duration_sec) * 100;
        const width = Math.max(((e.end - e.start) / duration_sec) * 100, 1.5);
        const bar = document.createElement("div");
        bar.className = "absolute top-1 bottom-1 rounded opacity-90 transition-all";
        bar.style.left = left + "%";
        bar.style.width = width + "%";
        bar.style.background = CLASS_COLORS[e.class] || "#94a3b8";
        bar.title = `${e.class_vi} (${e.start.toFixed(1)}s – ${e.end.toFixed(1)}s)`;
        timeline.appendChild(bar);
      });
      
      // Legend Rendering
      const seen = new Set(events.map((e) => e.class));
      timelineLegend.innerHTML = [...seen]
        .map(
          (c) =>
            `<span class="flex items-center gap-1.5"><span class="w-3.5 h-3.5 rounded-full inline-block" style="background:${CLASS_COLORS[c]}"></span>${c}</span>`
        )
        .join("");
    } else if (timelineSection) {
      timelineSection.classList.add("hidden");
    }
  }

  // --- Assessment form submit ---
  if (assessmentForm) {
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
        alert("Lỗi tải khuyến nghị: " + err.message);
      }
    });
  }

  // --- Render products in catalog ---
  function renderSuggestedProducts(coughType, subject) {
    if (!productsSection || !productsList) return;
    
    // Get corresponding product list based on cough type (default dry)
    let list = MOCK_PRODUCTS[coughType] || MOCK_PRODUCTS["dry"];
    const isPediatric = (subject === "child" || subject === "infant");

    productsSection.classList.remove("hidden");
    productsList.innerHTML = list.map((p) => {
      let finalName = p.name;
      let specialBadge = p.tag;
      let finalPrice = p.price;

      // Handle Pediatric Cases
      if (isPediatric) {
        if (p.name.includes("Prospan")) {
          finalName = "Siro ho trẻ em Prospan (Đức)";
          specialBadge = "Khuyên dùng cho bé";
        } else if (p.name.includes("Bảo Thanh")) {
          finalName = "Siro bổ phế Bảo Thanh (Chai Trẻ Em)";
          specialBadge = "Thảo dược dịu ngọt";
        } else if (p.name.includes("ACC200") || p.name.includes("Telfast")) {
          // If medication is inappropriate for kids, display a warn card
          return `
            <div class="border border-amber-200 bg-amber-50 rounded-xl p-3.5 flex gap-3 text-xs text-amber-800">
              <span class="text-base flex-shrink-0">⚠️</span>
              <div>
                <h4 class="font-bold">${p.name}</h4>
                <p class="mt-0.5 opacity-90">Sản phẩm này chủ yếu cho người lớn. Cần liên hệ Dược sĩ Long Châu để tư vấn liều dùng & thay thế thuốc siro phù hợp với trẻ nhỏ.</p>
              </div>
            </div>
          `;
        }
      }

      return `
        <div class="border border-gray-150 rounded-xl p-3.5 hover:border-longchau-blue/30 transition shadow-sm bg-white flex items-start gap-3 justify-between">
          <div class="w-12 h-12 rounded-lg bg-slate-50 flex items-center justify-center text-2xl border border-gray-100 flex-shrink-0">
            ${p.image}
          </div>
          <div class="flex-grow min-w-0">
            <div class="flex items-center gap-1.5 mb-1 flex-wrap">
              <span class="text-[9px] text-longchau-blue font-bold px-1.5 py-0.5 rounded bg-longchau-blueLight uppercase">${p.brand}</span>
              ${specialBadge ? `<span class="text-[9px] text-longchau-orange font-bold px-1.5 py-0.5 rounded bg-longchau-orangeLight">${specialBadge}</span>` : ''}
            </div>
            <h4 class="font-bold text-xs text-gray-800 truncate">${finalName}</h4>
            <p class="text-[10px] text-gray-400 mb-1.5">${p.unit} | ${p.desc}</p>
            <div class="flex items-baseline gap-1.5">
              <span class="text-xs font-extrabold text-longchau-orange">${finalPrice}</span>
              <span class="text-[8px] text-gray-400 line-through">${(parseInt(finalPrice) * 1.15).toFixed(0)}.000đ</span>
            </div>
          </div>
          <button type="button" class="bg-longchau-blue hover:bg-longchau-blueHover text-white px-3.5 py-2 rounded-lg text-[10px] font-bold transition flex items-center gap-1 flex-shrink-0 self-end" onclick="alert('Đã thêm ${finalName} vào giỏ hàng!')">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4"/></svg>
            Chọn mua
          </button>
        </div>
      `;
    }).join("");
  }

  function renderRecommendations(data) {
    if (outputColumn) {
      outputColumn.classList.remove("hidden");
    }
    if (assessmentSection) {
      assessmentSection.classList.remove("xl:col-span-9");
      assessmentSection.classList.add("xl:col-span-5");
    }
    recommendationSection.classList.remove("hidden");
    const { classification, recommendations, warnings, should_see_doctor } = data;

    // Red flag / urgent warnings
    const warningsDiv = document.getElementById("warnings");
    if (warnings && warnings.length) {
      warningsDiv.innerHTML = warnings
        .map((w) => `
          <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl p-3 text-xs font-semibold mb-2 flex gap-2 items-start">
            <span class="text-base flex-shrink-0">⚠️</span>
            <span>${w}</span>
          </div>`)
        .join("");
    } else {
      warningsDiv.innerHTML = "";
    }

    // Classification profile summary
    const summaryDiv = document.getElementById("classification-summary");
    if (summaryDiv) {
      summaryDiv.innerHTML = `
        <div class="grid grid-cols-2 gap-2 text-xs">
          <div><span class="text-gray-400 font-medium">Chẩn đoán ho:</span> <strong class="text-gray-800">${classification.cough_type_vi}</strong></div>
          <div><span class="text-gray-400 font-medium">Mức độ ho:</span> <strong class="text-gray-800 uppercase text-longchau-orange">${classification.severity}</strong></div>
          <div><span class="text-gray-400 font-medium font-semibold">Đối tượng:</span> <strong class="text-gray-800">${classification.subject_vi}</strong></div>
          <div><span class="text-gray-400 font-semibold">Thời gian ho:</span> <strong class="text-gray-800">${classification.duration_vi}</strong> <span class="text-[10px] text-gray-400">(${classification.duration_desc})</span></div>
        </div>
      `;
    }

    // Care items categories accordion list
    const recsDiv = document.getElementById("recommendations");
    if (recsDiv) {
      recsDiv.innerHTML = recommendations
        .map(
          (r) => `
          <div class="border rounded-xl p-4 transition-all duration-300 shadow-sm ${r.category === "see_doctor" ? "border-red-300 bg-red-50/50" : "border-gray-150 bg-slate-50/30"}">
            <h3 class="font-bold text-xs mb-1.5 flex items-center gap-1.5 ${r.category === "see_doctor" ? "text-red-700" : "text-gray-800"}">
              <span class="text-base">${r.category_icon}</span>
              <span>${r.category_label}</span>
            </h3>
            <ul class="list-disc list-inside text-xs text-gray-600 space-y-1 pl-1">
              ${r.items.map((item) => `<li>${item}</li>`).join("")}
            </ul>
          </div>`
        )
        .join("");
    }

    // Dynamic product catalog call
    renderSuggestedProducts(classification.cough_type, classification.subject);

    // Scroll to recommendations card
    recommendationSection.scrollIntoView({ behavior: "smooth" });
  }

  function showLoading() {
    resultsDiv.innerHTML = `
      <div class="flex items-center gap-3 text-longchau-blue font-bold animate-pulse py-2 text-xs">
        <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <span>Đang chẩn đoán giọng ho bằng mô hình AI...</span>
      </div>`;
    if (inferenceTime) inferenceTime.textContent = "";
  }

  function showError(msg) {
    resultsDiv.innerHTML = `
      <div class="bg-red-50 border border-red-200 rounded-xl p-3.5 text-xs text-red-700 flex gap-2 items-start">
        <span class="text-base flex-shrink-0">⚠️</span>
        <div>
          <h4 class="font-bold">Lỗi phân tích âm thanh</h4>
          <p class="mt-0.5 opacity-90">${msg}</p>
        </div>
      </div>`;
    if (inferenceTime) inferenceTime.textContent = "";
  }

  // Draw initial canvas visualizer flatline
  drawFlatLine();
  
  // Init samples
  loadSamples();
})();
