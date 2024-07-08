const main = document.querySelector('main');
const projectSection = document.querySelector('section.projects');
const contactSection = document.querySelector('section.contact-me');

// Hero section
const projectBtn = document.querySelector('div.portfolio-btn');
const contactBtn = document.querySelector('div.contact-btn');

// About Me
const aboutMeImages = document.querySelectorAll('div.image-selector span.images img');
const aboutMeLabels = document.querySelectorAll('div.description p');
const leftImageBtn = document.querySelector('div.image-selector button.left-arrow');
const rightImageBtn = document.querySelector('div.image-selector button.right-arrow');
let currentImgIndex = 0;

// Skills
const noSkillSelectedLabel = document.querySelector('div.label:has(p[data-skill="none"])');
const allSkills = document.querySelectorAll('span.tech-skills img');
let selectedSkill;
let selectedLabel;

/*******************/
/**** FUNCTIONS ****/
/*******************/

// Removes/adds one character to the element's inner text to get closer to the
// desired text
// Returns true if the element's current text matches the desired text, false otherwise
function incrementText(textNode, desiredText) {
    const length = textNode.nodeValue.length;
    const desiredLength = desiredText.length;

    if(desiredLength < length) {
        // Remove one character from the inner text
        textNode.nodeValue = textNode.nodeValue.substring(0, length - 1);
        return textNode.nodeValue == desiredText;
    }

    if(desiredLength >= length && desiredLength > 0) {
        // Remove one character from the inner text if any character before the
        // length of the current string is different
        for(let i = 0; i < length; i++) {
            if(desiredText[i] != textNode.nodeValue[i]) {
                textNode.nodeValue = textNode.nodeValue.substring(0, length - 1);
                return false;
            }
        }
    } 

    if(desiredLength > length) {
        const nextChar = desiredText[length];
        textNode.nodeValue += nextChar;
    }

    return textNode.nodeValue == desiredText;
}

// Delay utility function that can be awaited for
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Nav bar
function changeNavVisibility() {
    const mainY = main.getBoundingClientRect().top;

    if(mainY <= window.innerHeight / 2) {
        main.classList.add('nav-visible');
    } else {
        main.classList.remove('nav-visible');
    }
}

// About me section
function changeAboutImage(newIndex) {
    const prevImg = aboutMeImages[currentImgIndex];
    const prevLabel = aboutMeLabels[currentImgIndex];
    prevImg.classList.remove('selected');
    prevLabel.classList.remove('visible');

    currentImgIndex = newIndex;
    const currentImg = aboutMeImages[currentImgIndex];
    const currentLabel = aboutMeLabels[currentImgIndex];
    currentImg.classList.add('selected');
    currentLabel.classList.add('visible');
}

/*******************/
/* EVENT LISTENERS */
/*******************/

// Hero section
projectBtn.addEventListener('click', () => {
    window.scrollTo({
        top: projectSection.getBoundingClientRect().top,
        behavior: 'smooth'
    });
});

contactBtn.addEventListener('click', () => {
    window.scrollTo({
        top: contactSection.getBoundingClientRect().top,
        behavior: 'smooth'
    });
});

// Nav bar
window.addEventListener('scrollend', changeNavVisibility);

// About me section
leftImageBtn.addEventListener('click', () => {
    changeAboutImage((currentImgIndex - 1) >= 0 ? 
        (currentImgIndex - 1) : aboutMeImages.length - 1);
});
rightImageBtn.addEventListener('click', () => {
    changeAboutImage((currentImgIndex + 1) % aboutMeImages.length);
});
changeAboutImage(currentImgIndex);

// Skills section
allSkills.forEach(skill => {
    skill.addEventListener('click', () => {
        const dataSkill = skill.getAttribute('data-skill');
        const label = document.querySelector(`div.label:has(p[data-skill="${dataSkill}"])`);

        if(selectedSkill) {
            selectedSkill.classList.remove('selected');
            selectedLabel.classList.remove('visible');
        }

        if(selectedSkill == skill) {
            selectedSkill = null;
            selectedLabel = null;
            noSkillSelectedLabel.classList.add('visible');
            return;
        }

        selectedSkill = skill;
        selectedLabel = label;
        skill.classList.add('selected');
        label.classList.add('visible');
        noSkillSelectedLabel.classList.remove('visible');
    });
});

/******************/
/* INITIALIZATION */
/******************/

// In case the window starts under the hero section
changeNavVisibility(); 