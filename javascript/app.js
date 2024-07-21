"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
// Elements
const header = document.querySelector('header');
const main = document.querySelector('main');
const footer = document.querySelector('footer');
const aboutMeSection = document.querySelector('section.about-me');
const skillsSection = document.querySelector('section.skills');
const projectsSection = document.querySelector('section.projects');
const contactMeSection = document.querySelector('section.contact-me');
const headerIntro1 = document.querySelector('header h2');
const headerIntro2 = document.querySelector('header h3');
const titleView = document.querySelector('header .title');
const titleCursor = document.querySelector('header .title .cursor');
const siteVisitsView = document.querySelector('header .web-visits');
const siteVisitsCursor = document.querySelector('header .web-visits .cursor');
const fastForward = document.querySelector('.fast-forward');
const downBtn = document.querySelector('.down');
const upBtn = document.querySelector('.up');
const aboutMeSecBtns = document.querySelectorAll('button.about-me');
const skillsSecBtns = document.querySelectorAll('button.skills');
const projectsSecBtns = document.querySelectorAll('button.projects');
const contactMeSecBtns = document.querySelectorAll('button.contact-me');
const dropdownBtn = document.querySelector('button.dropdown');
const dropdownDiv = document.querySelector('.dropdown.mobile');
const galleryImages = document.querySelectorAll('.image-selector img');
const galleryDescriptions = document.querySelectorAll('.image-info .description p');
const galleryIndexView = document.querySelector('.image-info .pagination');
const galleryPrev = document.querySelector('.image-info .prev');
const galleryNext = document.querySelector('.image-info .next');
const nameDiv = document.querySelector('form .first-name');
const nameInput = document.querySelector('form .first-name input');
const emailDiv = document.querySelector('form .email');
const emailInput = document.querySelector('form .email input');
const messageDiv = document.querySelector('form .message');
const messageInput = document.querySelector('form .message textarea');
const contactSubmitBtn = document.querySelector('form .send');
// For me to view the types of certain elements
// const testEle = document.querySelector('div');
// const testEle2 = document.createTextNode('blah');
// Variable constants
const galleryLength = galleryImages.length;
const titles = ['Full Stack Developer', 'One Piece Connoisseur', 'Kagurabachi Advocate', 'The Cure to Cancer', 'You must be bored, huh?'];
// State
let galleryIndex = 0;
let siteVisits = 0;
let currentSectionBtns = null;
let titleIndex = 0;
let skipTyping = false;
/** FUNCTIONS **/
function typeText(element, text, cursor) {
    return __awaiter(this, void 0, void 0, function* () {
        if (element.nodeValue == null)
            return;
        if (cursor) {
            cursor.classList.remove('rest');
            cursor.classList.add('typing');
        }
        while (!incrementText(element, text) && !skipTyping) {
            yield delay(100);
        }
        element.nodeValue = text;
        if (cursor) {
            cursor.classList.remove('typing');
            cursor.classList.add('rest');
        }
    });
}
function scrollToSection(section) {
    window.scrollTo({
        top: section.getBoundingClientRect().top + window.scrollY - 80,
        behavior: 'smooth'
    });
}
function updateNavSection() {
    currentSectionBtns === null || currentSectionBtns === void 0 ? void 0 : currentSectionBtns.forEach((btn) => btn.classList.remove('enabled'));
    const updateBtns = (btn) => btn.classList.add('enabled');
    if (contactMeSection.getBoundingClientRect().y - window.innerHeight / 3 < 0) {
        currentSectionBtns = contactMeSecBtns;
        contactMeSecBtns.forEach(updateBtns);
    }
    else if (projectsSection.getBoundingClientRect().y - window.innerHeight / 3 < 0) {
        currentSectionBtns = projectsSecBtns;
        projectsSecBtns.forEach(updateBtns);
    }
    else if (skillsSection.getBoundingClientRect().y - window.innerHeight / 3 < 0) {
        currentSectionBtns = skillsSecBtns;
        skillsSecBtns.forEach(updateBtns);
    }
    else if (aboutMeSection.getBoundingClientRect().y - window.innerHeight / 3 < 0) {
        currentSectionBtns = aboutMeSecBtns;
        aboutMeSecBtns.forEach(updateBtns);
    }
    else {
        toggleDropdown(false);
    }
}
function changeGalleryPage(up) {
    // Unselect the previously selected image
    galleryImages[galleryIndex].classList.remove('selected');
    galleryDescriptions[galleryIndex].classList.remove('selected');
    if (up) {
        galleryIndex = galleryIndex + 1 < galleryLength ? galleryIndex + 1 : 0;
    }
    else {
        galleryIndex = galleryIndex - 1 >= 0 ? galleryIndex - 1 : galleryLength - 1;
    }
    // Select the new image
    setGallery();
}
function setGallery() {
    galleryImages[galleryIndex].classList.add('selected');
    galleryDescriptions[galleryIndex].classList.add('selected');
    galleryIndexView.textContent = (galleryIndex + 1) + '/' + galleryLength;
}
function toggleDropdown(open) {
    if (open == undefined) {
        dropdownBtn.classList.toggle('selected');
        dropdownDiv.classList.toggle('open');
    }
    else if (open) {
        dropdownBtn.classList.add('selected');
        dropdownDiv.classList.add('open');
    }
    else {
        dropdownBtn.classList.remove('selected');
        dropdownDiv.classList.remove('open');
    }
}
function submitContactForm(event) {
    // Prevent the default submit form behavior
    // https://www.geeksforgeeks.org/how-to-prevent-buttons-from-submitting-forms-in-html/
    event.preventDefault();
    nameDiv.classList.remove('invalid');
    emailDiv.classList.remove('invalid');
    messageDiv.classList.remove('invalid');
    const emailValid = () => emailInput.checkValidity()
        && emailInput.value.match('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!nameInput.checkValidity()) {
        nameDiv.classList.add('invalid');
    }
    if (!emailValid()) {
        emailDiv.classList.add('invalid');
    }
    if (!messageInput.checkValidity()) {
        messageDiv.classList.add('invalid');
    }
    if (nameInput.checkValidity() && emailValid() && messageInput.checkValidity()) {
        nameInput.value = '';
        emailInput.value = '';
        messageInput.value = '';
        contactMeSection.classList.add('success');
        setTimeout(() => {
            contactMeSection.classList.remove('success');
        }, 6000);
    }
}
function initHeader() {
    return __awaiter(this, void 0, void 0, function* () {
        // Get the website visits
        let visits = '';
        try {
            const res = yield fetch('https://s7gyrdfua8.execute-api.us-east-2.amazonaws.com/prod/portfolio', {
                method: "POST"
            });
            const resJson = yield res.json();
            // console.log(res);
            // console.log(resJson);
            // console.log(resJson.statusCode, resJson.body.count);
            visits = resJson.body.count;
        }
        catch (_a) {
            visits = 'idk yet';
        }
        // Add fast forward feature
        const skipAll = () => __awaiter(this, void 0, void 0, function* () {
            skipTyping = true;
            headerIntro1.classList.remove('fade-off');
            headerIntro2.classList.remove('fade-off');
            downBtn.classList.remove('fade-off');
            yield typeText(titleView.childNodes[0], "Full Stack Developer", titleCursor);
            yield typeText(siteVisitsView.childNodes[0], "Website visits: idk yet", siteVisitsCursor);
            titleCursor.classList.add('hidden');
            siteVisitsCursor.classList.remove('hidden');
            addFadeInAnims();
            main.classList.remove('hidden');
            footer.classList.remove('hidden');
            fastForward.removeEventListener('click', skipAll);
            fastForward.classList.add('hidden');
        });
        fastForward.addEventListener('click', skipAll);
        // Fade in the title
        headerIntro1.classList.remove('fade-off');
        yield delay(500);
        headerIntro2.classList.remove('fade-off');
        // Initalize the text
        yield delay(2000);
        titleCursor.classList.remove('hidden');
        yield typeText(titleView.childNodes[0], "Full Stack Developer", titleCursor);
        titleCursor.classList.add('hidden');
        siteVisitsCursor.classList.remove('hidden');
        yield typeText(siteVisitsView.childNodes[0], "Website visits: " + visits, siteVisitsCursor);
        // Make the rest of the website available
        addFadeInAnims();
        main.classList.remove('hidden');
        footer.classList.remove('hidden');
        downBtn.classList.remove('fade-off');
        // Remove the fast forward feature and animate the title
        fastForward.removeEventListener('click', skipAll);
        fastForward.classList.add('hidden');
        skipTyping = false;
        animHeaderTitle();
    });
}
function addFadeInAnims() {
    // Add an observer that removes the fade-off class from elements when
    // they're on the screen
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.remove('fade-off');
            }
        });
    });
    // Have the observer observe the fade-in elements
    document.querySelectorAll('.fade-in').forEach(element => {
        observer.observe(element);
    });
}
function animHeaderTitle() {
    return __awaiter(this, void 0, void 0, function* () {
        setTimeout(() => __awaiter(this, void 0, void 0, function* () {
            if (!siteVisitsCursor.classList.contains('hidden')) {
                siteVisitsCursor.classList.add('hidden');
            }
            titleCursor.classList.remove('hidden');
            titleIndex = (titleIndex + 1) % titles.length;
            yield typeText(titleView.childNodes[0], titles[titleIndex], titleCursor);
            animHeaderTitle();
        }), 5000);
    });
}
// Utility Functions //
// Removes or adds one character to the element's inner text to get closer to the
// desired text. Returns true if the element's current text matches the desired text,
// false otherwise.
function incrementText(textNode, desiredText) {
    if (textNode.nodeValue == null)
        return false;
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
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
/** EVENT LISTENERS **/
downBtn.addEventListener('click', () => scrollToSection(aboutMeSection));
upBtn.addEventListener('click', () => scrollToSection(header));
aboutMeSecBtns.forEach(btn => btn.addEventListener('click', () => scrollToSection(aboutMeSection)));
skillsSecBtns.forEach(btn => btn.addEventListener('click', () => scrollToSection(skillsSection)));
projectsSecBtns.forEach(btn => btn.addEventListener('click', () => scrollToSection(projectsSection)));
contactMeSecBtns.forEach(btn => btn.addEventListener('click', () => scrollToSection(contactMeSection)));
dropdownBtn.addEventListener('click', () => toggleDropdown());
document.addEventListener('scrollend', updateNavSection);
galleryPrev.addEventListener('click', () => changeGalleryPage(false));
galleryNext.addEventListener('click', () => changeGalleryPage(true));
contactSubmitBtn.addEventListener('click', submitContactForm);
/** INITIALIZATION **/
(() => __awaiter(void 0, void 0, void 0, function* () {
    setGallery();
    updateNavSection();
    initHeader();
}))();
