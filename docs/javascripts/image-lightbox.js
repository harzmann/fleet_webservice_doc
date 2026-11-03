(function () {
  "use strict";

  var lightbox = null;
  var lightboxImage = null;
  var lightboxCaption = null;
  var closeButton = null;
  var lastTrigger = null;
  var closeTimer = null;

  function isGerman() {
    return (document.documentElement.lang || "").toLowerCase().indexOf("de") === 0;
  }

  function labels() {
    if (isGerman()) {
      return {
        enlarge: "Screenshot vergrößern",
        close: "Bildansicht schließen",
        hint: "Klick auf das Bild: Originalgröße · Esc: Schließen"
      };
    }
    return {
      enlarge: "Enlarge screenshot",
      close: "Close image viewer",
      hint: "Click image: original size · Esc: close"
    };
  }

  function ensureLightbox() {
    if (lightbox) {
      return;
    }

    lightbox = document.createElement("div");
    lightbox.className = "fleet-mira-lightbox";
    lightbox.hidden = true;
    lightbox.setAttribute("role", "dialog");
    lightbox.setAttribute("aria-modal", "true");
    lightbox.setAttribute("aria-hidden", "true");
    lightbox.innerHTML =
      '<div class="fleet-mira-lightbox__backdrop" data-lightbox-close></div>' +
      '<div class="fleet-mira-lightbox__dialog">' +
      '  <button class="fleet-mira-lightbox__close" type="button">&times;</button>' +
      '  <div class="fleet-mira-lightbox__stage">' +
      '    <img class="fleet-mira-lightbox__image" alt="">' +
      '  </div>' +
      '  <div class="fleet-mira-lightbox__caption"></div>' +
      '</div>';
    document.body.appendChild(lightbox);

    lightboxImage = lightbox.querySelector(".fleet-mira-lightbox__image");
    lightboxCaption = lightbox.querySelector(".fleet-mira-lightbox__caption");
    closeButton = lightbox.querySelector(".fleet-mira-lightbox__close");

    closeButton.addEventListener("click", closeLightbox);
    lightbox.querySelector("[data-lightbox-close]").addEventListener("click", closeLightbox);
    lightboxImage.addEventListener("click", function () {
      lightbox.classList.toggle("is-actual-size");
    });
  }

  function openLightbox(image) {
    ensureLightbox();
    var text = labels();
    if (closeTimer !== null) {
      window.clearTimeout(closeTimer);
      closeTimer = null;
    }
    lastTrigger = image;
    lightboxImage.src = image.currentSrc || image.src;
    lightboxImage.alt = image.alt || "";
    lightboxCaption.textContent = (image.alt ? image.alt + " · " : "") + text.hint;
    closeButton.setAttribute("aria-label", text.close);
    closeButton.title = text.close;
    lightbox.classList.remove("is-actual-size");
    lightbox.hidden = false;
    lightbox.setAttribute("aria-hidden", "false");
    document.body.classList.add("fleet-mira-lightbox-open");
    window.requestAnimationFrame(function () {
      lightbox.classList.add("is-visible");
      closeButton.focus();
    });
  }

  function closeLightbox() {
    if (!lightbox || lightbox.hidden) {
      return;
    }
    lightbox.classList.remove("is-visible", "is-actual-size");
    lightbox.setAttribute("aria-hidden", "true");
    document.body.classList.remove("fleet-mira-lightbox-open");
    closeTimer = window.setTimeout(function () {
      lightbox.hidden = true;
      lightboxImage.removeAttribute("src");
      if (lastTrigger && document.contains(lastTrigger)) {
        lastTrigger.focus();
      }
      lastTrigger = null;
      closeTimer = null;
    }, 140);
  }

  function isScreenshot(image) {
    var source = image.currentSrc || image.getAttribute("src") || "";
    return /\.(avif|gif|jpe?g|png|svg|webp)(?:[?#]|$)/i.test(source);
  }

  function enhanceScreenshots(root) {
    var text = labels();
    (root || document).querySelectorAll(".md-content img").forEach(function (image) {
      if (!isScreenshot(image) || image.dataset.fleetMiraLightbox === "true") {
        return;
      }
      image.dataset.fleetMiraLightbox = "true";
      image.classList.add("fleet-mira-zoomable");
      image.setAttribute("role", "button");
      image.setAttribute("tabindex", "0");
      image.setAttribute("aria-label", (image.alt ? image.alt + ": " : "") + text.enlarge);
      image.title = text.enlarge;
      image.addEventListener("click", function (event) {
        event.preventDefault();
        event.stopPropagation();
        openLightbox(image);
      });
      image.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          openLightbox(image);
        }
      });
    });
  }

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      closeLightbox();
    }
  });

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () {
      enhanceScreenshots(document);
    });
  } else {
    enhanceScreenshots(document);
  }

  if (typeof document$ !== "undefined" && document$ && document$.subscribe) {
    document$.subscribe(function () {
      enhanceScreenshots(document);
    });
  }
}());
