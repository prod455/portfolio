// Mesma galeria da landing do Draftmoor: sem JavaScript tudo aparece; com ele, os botões trocam
// entre arte com produto e modelo vazio, e entre feed e Story.
if ('IntersectionObserver' in window && !matchMedia('(prefers-reduced-motion: reduce)').matches) {
  const events = ['scroll', 'wheel', 'touchmove', 'keydown'];
  const arm = () => {
    for (const name of events) removeEventListener(name, arm);
    const observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        entry.target.classList.add('in');
        observer.unobserve(entry.target);
      }
    }, { rootMargin: '0px 0px -6% 0px' });
    for (const element of document.querySelectorAll('[data-reveal]')) {
      if (element.getBoundingClientRect().top < innerHeight) continue;
      element.classList.add('rv');
      observer.observe(element);
    }
  };
  for (const name of events) addEventListener(name, arm, { passive: true });
}

const gallery = document.querySelector('[data-model-gallery]');
if (gallery) {
  const cards = [...gallery.querySelectorAll('[data-model-id]')];
  const kinds = [...document.querySelectorAll('[data-model-kind]')];
  const formats = [...document.querySelectorAll('[data-gallery-format]')];
  const formatGroup = document.querySelector('[data-format-group]');
  let kind = 'com';
  let format = 'feed';
  const press = (button, on) => {
    button.setAttribute('aria-pressed', String(on));
    button.dataset.variant = on ? 'primary' : 'outline';
  };
  const update = () => {
    // O modelo vazio existe só em Story.
    const view = kind === 'sem' ? 'story' : format;
    for (const card of cards) {
      const source = card.querySelector(kind === 'sem' ? '[data-model-empty]' : view === 'story' ? '[data-model-story]' : '[data-model-feed]');
      const image = card.querySelector('img');
      const preview = card.querySelector('[data-model-preview]');
      if (!(source instanceof HTMLAnchorElement) || !(image instanceof HTMLImageElement) || !(preview instanceof HTMLAnchorElement)) continue;
      if (image.src !== source.href) image.src = source.href;
      image.width = Number(source.dataset.width);
      image.height = Number(source.dataset.height);
      image.alt = source.dataset.alt ?? image.alt;
      preview.href = source.href;
    }
    gallery.dataset.galleryView = view;
    if (formatGroup) formatGroup.hidden = kind === 'sem';
    for (const button of kinds) press(button, button.dataset.modelKind === kind);
    for (const button of formats) press(button, button.dataset.galleryFormat === format);
    for (const label of document.querySelectorAll('[data-model-count]')) {
      label.textContent = kind === 'sem' ? '5 modelos vazios, em Story.' : `5 modelos com produto, em ${view === 'story' ? 'Story' : 'feed'}.`;
    }
  };
  for (const button of kinds) button.addEventListener('click', () => { kind = button.dataset.modelKind; update(); });
  for (const button of formats) button.addEventListener('click', () => { format = button.dataset.galleryFormat; update(); });
  for (const controls of document.querySelectorAll('[data-model-controls]')) controls.hidden = false;
  update();
}
