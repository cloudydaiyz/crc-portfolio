// Elements
const header = document.querySelector("header") as HTMLElement;
const main = document.querySelector("main") as HTMLElement;
const footer = document.querySelector("footer") as HTMLElement;

const aboutMeSection = document.querySelector(
  "section.about-me"
) as HTMLElement;
const skillsSection = document.querySelector("section.skills") as HTMLElement;
const projectsSection = document.querySelector(
  "section.projects"
) as HTMLElement;
const contactMeSection = document.querySelector(
  "section.contact-me"
) as HTMLElement;

const headerIntro1 = document.querySelector("header h2") as HTMLHeadingElement;
const headerIntro2 = document.querySelector("header h3") as HTMLHeadingElement;
const titleView = document.querySelector(
  "header .title"
) as HTMLParagraphElement;
const titleCursor = document.querySelector(
  "header .title .cursor"
) as HTMLSpanElement;
const siteVisitsView = document.querySelector(
  "header .web-visits"
) as HTMLParagraphElement;
const siteVisitsCursor = document.querySelector(
  "header .web-visits .cursor"
) as HTMLSpanElement;

const fastForward = document.querySelector(
  ".fast-forward"
) as HTMLButtonElement;
const downBtn = document.querySelector(".down") as HTMLButtonElement;
const upBtn = document.querySelector(".up") as HTMLButtonElement;

const aboutMeSecBtns = document.querySelectorAll(
  "button.about-me"
) as NodeListOf<HTMLButtonElement>;
const skillsSecBtns = document.querySelectorAll(
  "button.skills"
) as NodeListOf<HTMLButtonElement>;
const projectsSecBtns = document.querySelectorAll(
  "button.projects"
) as NodeListOf<HTMLButtonElement>;
const contactMeSecBtns = document.querySelectorAll(
  "button.contact-me"
) as NodeListOf<HTMLButtonElement>;

const dropdownBtn = document.querySelector(
  "button.dropdown"
) as HTMLButtonElement;
const dropdownDiv = document.querySelector(
  ".dropdown.mobile"
) as HTMLDivElement;

const galleryImages = document.querySelectorAll(
  ".image-selector img"
) as NodeListOf<HTMLImageElement>;
const galleryDescriptions = document.querySelectorAll(
  ".image-info .description p"
) as NodeListOf<HTMLParagraphElement>;
const galleryIndexView = document.querySelector(
  ".image-info .pagination"
) as HTMLHeadingElement;
const galleryPrev = document.querySelector(
  ".image-info .prev"
) as HTMLButtonElement;
const galleryNext = document.querySelector(
  ".image-info .next"
) as HTMLButtonElement;

const nameDiv = document.querySelector("form .first-name") as HTMLDivElement;
const nameInput = document.querySelector(
  "form .first-name input"
) as HTMLInputElement;
const emailDiv = document.querySelector("form .email") as HTMLDivElement;
const emailInput = document.querySelector(
  "form .email input"
) as HTMLInputElement;
const messageDiv = document.querySelector("form .message") as HTMLDivElement;
const messageInput = document.querySelector(
  "form .message textarea"
) as HTMLTextAreaElement;
const contactSubmitBtn = document.querySelector(
  "form .send"
) as HTMLButtonElement;

// For me to view the types of certain elements
// const testEle = document.querySelector('div');
// const testEle2 = document.createTextNode('blah');

// Variable constants
const galleryLength = galleryImages.length;
const titles = [
  "Full Stack Developer",
  "One Piece Connoisseur",
  "Kagurabachi Advocate",
  "The Cure to Cancer",
  "You must be bored, huh?",
];

// State
let galleryIndex = 0;
let siteVisits = 0;
let currentSectionBtns: NodeListOf<HTMLButtonElement> | null = null;
let titleIndex = 0;
let skipTyping = false;

/** FUNCTIONS **/
async function typeText(element: Text, text: string, cursor: Element) {
  if (element.nodeValue == null) return;

  if (cursor) {
    cursor.classList.remove("rest");
    cursor.classList.add("typing");
  }

  while (!incrementText(element, text) && !skipTyping) {
    await delay(100);
  }
  element.nodeValue = text;

  if (cursor) {
    cursor.classList.remove("typing");
    cursor.classList.add("rest");
  }
}

function scrollToSection(section: HTMLElement) {
  window.scrollTo({
    top: section.getBoundingClientRect().top + window.scrollY - 80,
    behavior: "smooth",
  });
}

function updateNavSection() {
  currentSectionBtns?.forEach((btn) => btn.classList.remove("enabled"));
  const updateBtns = (btn: HTMLButtonElement) => btn.classList.add("enabled");

  if (contactMeSection.getBoundingClientRect().y - window.innerHeight / 3 < 0) {
    currentSectionBtns = contactMeSecBtns;
    contactMeSecBtns.forEach(updateBtns);
  } else if (
    projectsSection.getBoundingClientRect().y - window.innerHeight / 3 <
    0
  ) {
    currentSectionBtns = projectsSecBtns;
    projectsSecBtns.forEach(updateBtns);
  } else if (
    skillsSection.getBoundingClientRect().y - window.innerHeight / 3 <
    0
  ) {
    currentSectionBtns = skillsSecBtns;
    skillsSecBtns.forEach(updateBtns);
  } else if (
    aboutMeSection.getBoundingClientRect().y - window.innerHeight / 3 <
    0
  ) {
    currentSectionBtns = aboutMeSecBtns;
    aboutMeSecBtns.forEach(updateBtns);
  } else {
    toggleDropdown(false);
  }
}

function changeGalleryPage(up: boolean) {
  // Unselect the previously selected image
  galleryImages[galleryIndex].classList.remove("selected");
  galleryDescriptions[galleryIndex].classList.remove("selected");

  if (up) {
    galleryIndex = galleryIndex + 1 < galleryLength ? galleryIndex + 1 : 0;
  } else {
    galleryIndex = galleryIndex - 1 >= 0 ? galleryIndex - 1 : galleryLength - 1;
  }

  // Select the new image
  setGallery();
}

function setGallery() {
  galleryImages[galleryIndex].classList.add("selected");
  galleryDescriptions[galleryIndex].classList.add("selected");
  galleryIndexView.textContent = galleryIndex + 1 + "/" + galleryLength;
}

function toggleDropdown(open?: boolean) {
  if (open == undefined) {
    dropdownBtn.classList.toggle("selected");
    dropdownDiv.classList.toggle("open");
  } else if (open) {
    dropdownBtn.classList.add("selected");
    dropdownDiv.classList.add("open");
  } else {
    dropdownBtn.classList.remove("selected");
    dropdownDiv.classList.remove("open");
  }
}

function submitContactForm(event: Event) {
  // Prevent the default submit form behavior
  // https://www.geeksforgeeks.org/how-to-prevent-buttons-from-submitting-forms-in-html/
  event.preventDefault();
  nameDiv.classList.remove("invalid");
  emailDiv.classList.remove("invalid");
  messageDiv.classList.remove("invalid");

  const emailValid = () =>
    emailInput.checkValidity() &&
    emailInput.value.match("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$");

  if (!nameInput.checkValidity()) {
    nameDiv.classList.add("invalid");
  }

  if (!emailValid()) {
    emailDiv.classList.add("invalid");
  }

  if (!messageInput.checkValidity()) {
    messageDiv.classList.add("invalid");
  }

  if (
    nameInput.checkValidity() &&
    emailValid() &&
    messageInput.checkValidity()
  ) {
    nameInput.value = "";
    emailInput.value = "";
    messageInput.value = "";

    contactMeSection.classList.add("success");
    setTimeout(() => {
      contactMeSection.classList.remove("success");
    }, 6000);
  }
}

async function initHeader() {
  // Get the website visits
  let visits = "";
  try {
    const res = await fetch("https://api.crc.cloudydaiyz.com/portfolio", {
      method: "POST",
    });
    const resJson = await res.json();
    // console.log(res);
    // console.log(resJson);
    // console.log(resJson.statusCode, resJson.body.count);

    visits = resJson.body.count;
  } catch {
    visits = "idk yet";
  }

  // Add fast forward feature
  const skipAll = async () => {
    skipTyping = true;

    headerIntro1.classList.remove("fade-off");
    headerIntro2.classList.remove("fade-off");
    downBtn.classList.remove("fade-off");
    await typeText(
      titleView.childNodes[0] as Text,
      "Full Stack Developer",
      titleCursor as Element
    );
    await typeText(
      siteVisitsView.childNodes[0] as Text,
      "Website visits: idk yet",
      siteVisitsCursor as Element
    );

    titleCursor.classList.add("hidden");
    siteVisitsCursor.classList.remove("hidden");
    addFadeInAnims();
    main.classList.remove("hidden");
    footer.classList.remove("hidden");

    fastForward.removeEventListener("click", skipAll);
    fastForward.classList.add("hidden");
  };
  fastForward.addEventListener("click", skipAll);

  // Fade in the title
  headerIntro1.classList.remove("fade-off");
  await delay(500);
  headerIntro2.classList.remove("fade-off");

  // Initalize the text
  await delay(2000);
  titleCursor.classList.remove("hidden");
  await typeText(
    titleView.childNodes[0] as Text,
    "Full Stack Developer",
    titleCursor as Element
  );
  titleCursor.classList.add("hidden");
  siteVisitsCursor.classList.remove("hidden");
  await typeText(
    siteVisitsView.childNodes[0] as Text,
    "Website visits: " + visits,
    siteVisitsCursor as Element
  );

  // Make the rest of the website available
  addFadeInAnims();
  main.classList.remove("hidden");
  footer.classList.remove("hidden");
  downBtn.classList.remove("fade-off");

  // Remove the fast forward feature and animate the title
  fastForward.removeEventListener("click", skipAll);
  fastForward.classList.add("hidden");
  skipTyping = false;
  animHeaderTitle();
}

function addFadeInAnims() {
  // Add an observer that removes the fade-off class from elements when
  // they're on the screen
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.remove("fade-off");
      }
    });
  });

  // Have the observer observe the fade-in elements
  document.querySelectorAll(".fade-in").forEach((element) => {
    observer.observe(element);
  });
}

async function animHeaderTitle() {
  setTimeout(async () => {
    if (!siteVisitsCursor.classList.contains("hidden")) {
      siteVisitsCursor.classList.add("hidden");
    }

    titleCursor.classList.remove("hidden");
    titleIndex = (titleIndex + 1) % titles.length;
    await typeText(
      titleView.childNodes[0] as Text,
      titles[titleIndex],
      titleCursor as Element
    );
    animHeaderTitle();
  }, 5000);
}

// Utility Functions //
// Removes or adds one character to the element's inner text to get closer to the
// desired text. Returns true if the element's current text matches the desired text,
// false otherwise.
function incrementText(textNode: Text, desiredText: string) {
  if (textNode.nodeValue == null) return false;

  const length = textNode.nodeValue.length;
  const desiredLength = desiredText.length;

  if (desiredLength < length) {
    // remove one character from the inner text
    textNode.nodeValue = textNode.nodeValue.substring(0, length - 1);
    return textNode.nodeValue == desiredText;
  }

  if (desiredLength >= length && desiredLength > 0) {
    // Remove one character from the inner text if any character before the
    // length of the current string is different
    for (let i = 0; i < length; i++) {
      if (desiredText[i] != textNode.nodeValue[i]) {
        textNode.nodeValue = textNode.nodeValue.substring(0, length - 1);
        return false;
      }
    }
  }

  if (desiredLength > length) {
    const nextChar = desiredText[length];
    textNode.nodeValue += nextChar;
  }

  return textNode.nodeValue == desiredText;
}

// Delay utility function that can be awaited for
function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/** EVENT LISTENERS **/
downBtn.addEventListener("click", () => scrollToSection(aboutMeSection));
upBtn.addEventListener("click", () => scrollToSection(header));

aboutMeSecBtns.forEach((btn) =>
  btn.addEventListener("click", () => scrollToSection(aboutMeSection))
);
skillsSecBtns.forEach((btn) =>
  btn.addEventListener("click", () => scrollToSection(skillsSection))
);
projectsSecBtns.forEach((btn) =>
  btn.addEventListener("click", () => scrollToSection(projectsSection))
);
contactMeSecBtns.forEach((btn) =>
  btn.addEventListener("click", () => scrollToSection(contactMeSection))
);
dropdownBtn.addEventListener("click", () => toggleDropdown());

document.addEventListener("scrollend", updateNavSection);

galleryPrev.addEventListener("click", () => changeGalleryPage(false));
galleryNext.addEventListener("click", () => changeGalleryPage(true));

contactSubmitBtn.addEventListener("click", submitContactForm);

/** INITIALIZATION **/
(async () => {
  setGallery();
  updateNavSection();
  initHeader();
})();
