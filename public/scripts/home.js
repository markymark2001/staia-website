document.querySelectorAll(".review-track").forEach((track) => {
  const groups = track.querySelectorAll(".review-group");
  const template = groups[1] || groups[0];
  if (!template) return;

  const existing = track.querySelectorAll(".review-group").length;
  for (let i = existing; i < 4; i += 1) {
    const clone = template.cloneNode(true);
    clone.setAttribute("aria-hidden", "true");
    track.appendChild(clone);
  }
});

const heroVideo = document.querySelector(".video-hero__media");
const heroRippleVideo = document.querySelector(".video-hero__ripple-media");
const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

const syncVideoPair = () => {
  if (!heroVideo || !heroRippleVideo) return;

  if (Number.isFinite(heroVideo.duration) && Math.abs(heroRippleVideo.currentTime - heroVideo.currentTime) > 0.18) {
    heroRippleVideo.currentTime = heroVideo.currentTime;
  }
};

const syncHeroVideoMotion = () => {
  if (!heroVideo) return;

  if (reducedMotion.matches) {
    heroVideo.pause();
    heroRippleVideo?.pause();
    return;
  }

  heroVideo.play().catch(() => {});
  if (heroRippleVideo) {
    syncVideoPair();
    heroRippleVideo.play().catch(() => {});
  }
};

syncHeroVideoMotion();
reducedMotion.addEventListener("change", syncHeroVideoMotion);
heroVideo?.addEventListener("timeupdate", syncVideoPair);

const header = document.querySelector(".site-header");
const heroCta = document.querySelector(".video-hero__bottom .button");

const syncHeader = () => {
  const ctaHasScrolledOut = heroCta
    ? heroCta.getBoundingClientRect().bottom <= 0
    : window.scrollY > 40;
  header?.classList.toggle("is-visible", ctaHasScrolledOut);
};

syncHeader();
window.addEventListener("scroll", syncHeader, { passive: true });
window.addEventListener("resize", syncHeader);

const setupHeroSurfaceRipple = () => {
  const hero = document.querySelector(".video-hero");
  const ripple = document.querySelector(".video-hero__ripple");
  const displacementMap = document.querySelector("#hero-ripple-displacement");
  const finePointer = window.matchMedia("(hover: hover) and (pointer: fine)");

  if (!hero || !ripple || !displacementMap || reducedMotion.matches || !finePointer.matches) return;

  const state = {
    currentOpacity: 0,
    currentX: 50,
    currentY: 50,
    currentRadius: 0,
    currentScale: 0,
    hasPointer: false,
    lastX: 0,
    lastY: 0,
    targetOpacity: 0,
    targetX: 50,
    targetY: 50,
    targetRadius: 0,
    targetScale: 0,
    rafId: 0
  };

  const lerp = (start, end, amount) => start + (end - start) * amount;

  const readPointer = (event) => {
    const rect = hero.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const dx = state.hasPointer ? x - state.lastX : 0;
    const dy = state.hasPointer ? y - state.lastY : 0;
    const velocity = Math.min(1, Math.hypot(dx, dy) / 44);

    state.hasPointer = true;
    state.lastX = x;
    state.lastY = y;
    state.targetX = (x / rect.width) * 100;
    state.targetY = (y / rect.height) * 100;
    state.targetRadius = 96 + velocity * 130;
    state.targetScale = 12 + velocity * 26;
    state.targetOpacity = 1;
  };

  const renderRipple = () => {
    state.currentOpacity = lerp(state.currentOpacity, state.targetOpacity, 0.2);
    state.currentX = lerp(state.currentX, state.targetX, 0.22);
    state.currentY = lerp(state.currentY, state.targetY, 0.22);
    state.currentRadius = lerp(state.currentRadius, state.targetRadius, 0.18);
    state.currentScale = lerp(state.currentScale, state.targetScale, 0.2);

    ripple.style.setProperty("--ripple-x", `${state.currentX.toFixed(2)}%`);
    ripple.style.setProperty("--ripple-y", `${state.currentY.toFixed(2)}%`);
    ripple.style.setProperty("--ripple-radius", `${state.currentRadius.toFixed(1)}px`);
    ripple.style.setProperty("--ripple-opacity", state.currentOpacity.toFixed(3));
    ripple.style.setProperty("--ripple-scale", (1.012 + state.currentScale / 1800).toFixed(4));
    displacementMap.setAttribute("scale", state.currentScale.toFixed(2));

    if (state.currentOpacity > 0.01 || state.currentRadius > 0.8 || state.currentScale > 0.8) {
      state.rafId = window.requestAnimationFrame(renderRipple);
      return;
    }

    state.rafId = 0;
  };

  const ensureRenderLoop = () => {
    if (!state.rafId) {
      state.rafId = window.requestAnimationFrame(renderRipple);
    }
  };

  hero.addEventListener("pointerenter", (event) => {
    readPointer(event);
    ensureRenderLoop();
  });

  hero.addEventListener("pointermove", (event) => {
    readPointer(event);
    ensureRenderLoop();
  }, { passive: true });

  hero.addEventListener("pointerleave", () => {
    state.hasPointer = false;
    state.targetOpacity = 0;
    state.targetRadius = 0;
    state.targetScale = 0;
    ensureRenderLoop();
  });

  reducedMotion.addEventListener("change", () => {
    if (reducedMotion.matches && state.rafId) {
      window.cancelAnimationFrame(state.rafId);
      state.rafId = 0;
      ripple.removeAttribute("style");
      displacementMap.setAttribute("scale", "0");
    }
  });
};

setupHeroSurfaceRipple();
