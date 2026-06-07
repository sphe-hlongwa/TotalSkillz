const fs = require('fs');
const path = require('path');

let questions = [];

// Helper to shuffle options and track the correct answer index
function createQuestion(topic, q, rawOptions, correctOptIndex, solution) {
    // Generate a list of objects with the original option and whether it's the correct one
    let optionsWithMeta = rawOptions.map((opt, idx) => ({
        text: opt,
        isCorrect: idx === correctOptIndex
    }));

    // Shuffle the options
    for (let i = optionsWithMeta.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [optionsWithMeta[i], optionsWithMeta[j]] = [optionsWithMeta[j], optionsWithMeta[i]];
    }

    // Find the new index of the correct answer
    const newCorrectIndex = optionsWithMeta.findIndex(opt => opt.isCorrect);

    questions.push({
        topic,
        q,
        options: optionsWithMeta.map(opt => opt.text),
        answer: newCorrectIndex,
        solution
    });
}

function randInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randNonZero(min, max) {
    let r = 0;
    while (r === 0) { r = randInt(min, max); }
    return r;
}

// --------------------------------------------------------------------------
// GENERATORS
// --------------------------------------------------------------------------

// 1. ALGEBRA
function generateAlgebra() {
    // Quadratic factorisation
    for (let i = 0; i < 5; i++) {
        let r1 = randNonZero(-8, 8);
        let r2 = randNonZero(-8, 8);
        if (r1 === r2) r2++;
        let b = -(r1 + r2);
        let c = r1 * r2;
        let bStr = b > 0 ? `+ ${b}x` : (b < 0 ? `- ${Math.abs(b)}x` : '');
        let cStr = c > 0 ? `+ ${c}` : (c < 0 ? `- ${Math.abs(c)}` : '');
        let q = `Solve for \\(x\\): \\(x^2 ${bStr} ${cStr} = 0\\)`;

        let correct = `\\(x = ${r1}\\) or \\(x = ${r2}\\)`;
        let wrong1 = `\\(x = ${-r1}\\) or \\(x = ${-r2}\\)`;
        let wrong2 = `\\(x = ${r1}\\) or \\(x = ${-r2}\\)`;
        let wrong3 = `\\(x = ${-r1}\\) or \\(x = ${r2}\\)`;

        createQuestion('algebra', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Factorise the quadratic: \\((x - ${r1})(x - ${r2}) = 0\\)`,
            `Set each factor to zero: \\(x - ${r1} = 0\\) or \\(x - ${r2} = 0\\)`,
            correct
        ]);
    }

    // Quadratic Formula
    for (let i = 0; i < 5; i++) {
        let a = randNonZero(2, 5);
        let b = randNonZero(3, 9);
        let c = randNonZero(-5, -1);
        let q = `Solve for \\(x\\): \\(${a}x^2 + ${b}x ${c} = 0\\) (correct to TWO decimal places)`;

        let disc = b * b - 4 * a * c;
        let x1 = (-b + Math.sqrt(disc)) / (2 * a);
        let x2 = (-b - Math.sqrt(disc)) / (2 * a);

        let correct = `\\(x \\approx ${x1.toFixed(2)}\\) or \\(x \\approx ${x2.toFixed(2)}\\)`;
        let wrong1 = `\\(x \\approx ${(-x1).toFixed(2)}\\) or \\(x \\approx ${(-x2).toFixed(2)}\\)`;
        let wrong2 = `\\(x \\approx ${x1.toFixed(2)}\\) or \\(x \\approx ${(-x2).toFixed(2)}\\)`;
        let wrong3 = `\\(x \\approx ${(-x1).toFixed(2)}\\) or \\(x \\approx ${x2.toFixed(2)}\\)`;

        createQuestion('algebra', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Use the quadratic formula: \\(x = \\dfrac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\\)`,
            `Substitute values: \\(x = \\dfrac{-(${b}) \\pm \\sqrt{(${b})^2 - 4(${a})(${c})}}{2(${a})}\\)`,
            `\\(x = \\dfrac{-${b} \\pm \\sqrt{${disc}}}{${2 * a}}\\)`,
            correct
        ]);
    }

    // Simultaneous Equations
    for (let i = 0; i < 5; i++) {
        let yInt = randInt(2, 6);
        let radiusSq = randInt(10, 30);
        let q = `Given \\(y = x - ${yInt}\\) and \\(x^2 + y^2 = ${radiusSq}\\), find the coordinates of the points of intersection.`;

        let wrong1 = `\\((0, ${-yInt})\\) and \\((${Math.sqrt(radiusSq).toFixed(1)}, 0)\\)`;
        let wrong2 = `Two non-real solutions`;
        let wrong3 = `\\((1, ${1 - yInt})\\) only`;

        createQuestion('algebra', q, ["Evaluate algebraically by substitution", wrong1, wrong2, wrong3], 0, [
            `Substitute linear into quadratic: \\(x^2 + (x - ${yInt})^2 = ${radiusSq}\\)`,
            `Expand: \\(x^2 + x^2 - ${2 * yInt}x + ${yInt * yInt} = ${radiusSq}\\)`,
            `Simplify to standard quadratic form \\(ax^2 + bx + c = 0\\) and solve for x.`,
            `Substitute x values back into \\(y = x - ${yInt}\\) to find corresponding y values.`
        ]);
    }
}

// 2. PATTERNS
function generatePatterns() {
    // Arithmetic
    for (let i = 0; i < 5; i++) {
        let a = randInt(-10, 10);
        let d = randNonZero(-5, 5);
        let termNo = randInt(20, 50);
        let val = a + (termNo - 1) * d;
        let q = `Determine the ${termNo}th term of the arithmetic sequence: ${a}; ${a + d}; ${a + 2 * d}; ...`;

        createQuestion('patterns', q, [`\\(${val}\\)`, `\\(${val - d}\\)`, `\\(${val + d}\\)`, `\\(${a + termNo * d}\\)`], 0, [
            `Formula for arithmetic sequence: \\(T_n = a + (n-1)d\\)`,
            `Here, \\(a = ${a}\\) and \\(d = ${d}\\)`,
            `\\(T_{${termNo}} = ${a} + (${termNo}-1)(${d})\\)`,
            `\\(T_{${termNo}} = ${a} + ${d * (termNo - 1)} = ${val}\\)`
        ]);
    }

    // Geometric sum to infinity
    for (let i = 0; i < 5; i++) {
        let a = randInt(10, 50);
        let rNum = 1;
        let rDen = randInt(2, 5);
        let S_inf = a / (1 - (rNum / rDen));
        let q = `Calculate the sum to infinity of the geometric series: \\(${a} + ${a * (rNum / rDen)} + ...\\)`;

        createQuestion('patterns', q, [`\\(${S_inf}\\)`, `\\(${S_inf * (rNum / rDen)}\\)`, `Does not converge`, `\\(${a * rDen}\\)`], 0, [
            `Sum to infinity formula: \\(S_{\\infty} = \\dfrac{a}{1 - r}\\)`,
            `Here, \\(a = ${a}\\) and \\(r = \\dfrac{${rNum}}{${rDen}}\\)`,
            `\\(S_{\\infty} = \\dfrac{${a}}{1 - ${rNum}/${rDen}}\\)`,
            `\\(S_{\\infty} = ${S_inf}\\)`
        ]);
    }

    // Quadratic Sequences
    for (let i = 0; i < 5; i++) {
        let a2 = randInt(1, 4); // 2a
        let a = a2 / 2;
        let b = randInt(-3, 3);
        let c = randInt(-5, 5);
        let t1 = a * 1 * 1 + b * 1 + c;
        let t2 = a * 2 * 2 + b * 2 + c;
        let t3 = a * 3 * 3 + b * 3 + c;
        let t4 = a * 4 * 4 + b * 4 + c;
        let t5 = a * 5 * 5 + b * 5 + c;

        let q = `Determine the general term \\(T_n\\) of the quadratic sequence: ${t1}; ${t2}; ${t3}; ${t4}; ...`;
        let correct = `\\(T_n = ${a}n^2 ${b >= 0 ? '+' + b : b}n ${c >= 0 ? '+' + c : c}\\)`.replace("1n", "n").replace("+0n", "").replace("+0", "");
        let wrong1 = `\\(T_n = ${a2}n^2 + ${b + 1}n - ${c}\\)`.replace("1n", "n");
        let wrong2 = `\\(T_n = ${a}n^2 - ${b}n + ${c}\\)`.replace("1n", "n");
        let wrong3 = `\\(T_n = ${c}n^2 + ${b}n + ${a}\\)`.replace("1n", "n");

        createQuestion('patterns', q, [correct, wrong1, wrong2, wrong3], 0, [
            `First differences: ${t2 - t1}, ${t3 - t2}, ${t4 - t3}`,
            `Second difference: ${a2}. So \\(2a = ${a2} \\implies a = ${a}\\)`,
            `\\(3a + b = ${t2 - t1} \\implies 3(${a}) + b = ${t2 - t1} \\implies b = ${b}\\)`,
            `\\(a + b + c = ${t1} \\implies ${a} + ${b} + c = ${t1} \\implies c = ${c}\\)`,
            correct
        ]);
    }
}

// 3. FUNCTIONS
function generateFunctions() {
    // Parabola Vertex
    for (let i = 0; i < 5; i++) {
        let a = randNonZero(-3, 3);
        let h = randInt(-5, 5);
        let k = randInt(-10, 10);

        let q = `Determine the turning point of the parabola: \\(y = ${a}(x ${h >= 0 ? '- ' + h : '+ ' + Math.abs(h)})^2 ${k >= 0 ? '+ ' + k : '- ' + Math.abs(k)}\\)`;
        let correct = `\\((${h}; ${k})\\)`;
        let wrong1 = `\\((${h}; ${-k})\\)`;
        let wrong2 = `\\((${-h}; ${k})\\)`;
        let wrong3 = `\\((${-h}; ${-k})\\)`;

        createQuestion('functions', q, [correct, wrong1, wrong2, wrong3], 0, [
            `The equation is given in vertex form: \\(y = a(x - p)^2 + q\\)`,
            `The turning point is \\((p; q)\\)`,
            `Therefore, the turning point is ${correct}`
        ]);
    }

    // Inverse of Exponential
    for (let i = 0; i < 5; i++) {
        let base = randInt(2, 5);
        let q = `Determine the equation of the inverse of the function \\(f(x) = ${base}^x\\)`;
        let correct = `\\(f^{-1}(x) = \\log_{${base}} x\\)`;
        let wrong1 = `\\(f^{-1}(x) = ${base}^{-x}\\)`;
        let wrong2 = `\\(f^{-1}(x) = \\log_x ${base}\\)`;
        let wrong3 = `\\(f^{-1}(x) = \\dfrac{1}{${base}^x}\\)`;

        createQuestion('functions', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Let \\(y = f(x)\\), so \\(y = ${base}^x\\)`,
            `To find inverse, swap x and y: \\(x = ${base}^y\\)`,
            `Solve for y by converting to log form: \\(y = \\log_{${base}} x\\)`,
            `Therefore, ${correct}`
        ]);
    }

    // Hyperbola Asymptotes
    for (let i = 0; i < 5; i++) {
        let p = randNonZero(-5, 5);
        let q_val = randNonZero(-5, 5);
        let q = `State the equations of the asymptotes for the function: \\(h(x) = \\dfrac{2}{x ${p > 0 ? '+ ' + p : '- ' + Math.abs(p)}} ${q_val > 0 ? '+ ' + q_val : '- ' + Math.abs(q_val)}\\)`;
        let correct = `\\(x = ${-p}\\) and \\(y = ${q_val}\\)`;
        let wrong1 = `\\(x = ${p}\\) and \\(y = ${-q_val}\\)`;
        let wrong2 = `\\(x = ${-p}\\) and \\(y = ${-q_val}\\)`;
        let wrong3 = `\\(x = ${p}\\) and \\(y = ${q_val}\\)`;

        createQuestion('functions', q, [correct, wrong1, wrong2, wrong3], 0, [
            `For a hyperbola in the form \\(y = \\dfrac{a}{x - p} + q\\), the asymptotes are \\(x = p\\) and \\(y = q\\).`,
            `The denominator is zero when \\(x ${p > 0 ? '+' + p : p} = 0 \\implies x = ${-p}\\) (Vertical asymptote)`,
            `The horizontal shift is \\(y = ${q_val}\\) (Horizontal asymptote)`,
            `Therefore, ${correct}`
        ]);
    }
}

// 4. CALCULUS
function generateCalculus() {
    // Differentiation rules
    for (let i = 0; i < 5; i++) {
        let a = randInt(2, 6);
        let b = randInt(2, 5);
        let q = `Determine \\(\\frac{dy}{dx}\\) if \\(y = ${a}x^${b} - \\dfrac{${a}}{x^2}\\)`;
        let correct = `\\(${a * b}x^${b - 1} + \\dfrac{${2 * a}}{x^3}\\)`;
        let wrong1 = `\\(${a * b}x^${b - 1} - \\dfrac{${2 * a}}{x^3}\\)`;
        let wrong2 = `\\(${a * b}x^${b - 1} + \\dfrac{${a}}{x^3}\\)`;
        let wrong3 = `\\(${a * b}x^${b} + \\dfrac{${2 * a}}{x^2}\\)`;

        createQuestion('calculus', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Rewrite the expression with negative exponents: \\(y = ${a}x^${b} - ${a}x^{-2}\\)`,
            `Apply the power rule \\((nx^{n-1})\\):`,
            `\\(\\frac{dy}{dx} = ${a}(${b})x^{${b}-1} - ${a}(-2)x^{-2-1}\\)`,
            `\\(\\frac{dy}{dx} = ${a * b}x^${b - 1} + ${2 * a}x^{-3}\\)`,
            `Write with positive exponents: ${correct}`
        ]);
    }

    // Turning points
    for (let i = 0; i < 5; i++) {
        let r1 = randNonZero(-3, 3);
        let r2 = randNonZero(-3, 3);
        if (r1 === r2) r2++;
        let a = 1; // Make it simple

        let q = `Find the x-coordinates of the turning points of \\(f(x)\\) if \\(f'(x) = (x - ${r1})(x - ${r2})\\)`;
        let correct = `\\(x = ${r1}\\) and \\(x = ${r2}\\)`;
        let wrong1 = `\\(x = ${-r1}\\) and \\(x = ${-r2}\\)`;
        let wrong2 = `\\(x = 0\\)`;
        let wrong3 = `There are no turning points.`;

        createQuestion('calculus', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Turning points occur where the first derivative is zero: \\(f'(x) = 0\\)`,
            `\\((x - ${r1})(x - ${r2}) = 0\\)`,
            correct
        ]);
    }

    // Optimization (Basic)
    for (let i = 0; i < 5; i++) {
        let lengthSum = randInt(20, 60); // 2x + y = lengthSum
        let q = `A farmer has ${lengthSum}m of fencing to enclose a rectangular area against a straight river. No fencing is needed along the river. Find the maximum area he can enclose.`;
        let x = lengthSum / 4;
        let y = lengthSum / 2;
        let maxArea = x * y;

        let correct = `\\(${maxArea}\\text{ m}^2\\)`;
        let wrong1 = `\\(${(lengthSum / 3) * (lengthSum / 3)}\\text{ m}^2\\)`;
        let wrong2 = `\\(${maxArea * 2}\\text{ m}^2\\)`;
        let wrong3 = `\\(${lengthSum * lengthSum}\\text{ m}^2\\)`;

        createQuestion('calculus', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Let width be \\(x\\) and length against river be \\(y\\). Perimeter \\(2x + y = ${lengthSum} \\implies y = ${lengthSum} - 2x\\)`,
            `Area \\(A = x \\cdot y = x(${lengthSum} - 2x) = ${lengthSum}x - 2x^2\\)`,
            `To maximize, set derivative to zero: \\(A' = ${lengthSum} - 4x = 0 \\implies 4x = ${lengthSum} \\implies x = ${x}\\)`,
            `Substitute \\(x\\) back: \\(y = ${lengthSum} - 2(${x}) = ${y}\\)`,
            `Max Area \\(A = (${x})(${y}) = ${maxArea}\\)`
        ]);
    }
}

// 5. FINANCE
function generateFinance() {
    for (let i = 0; i < 5; i++) {
        let P = randInt(5, 20) * 1000;
        let r = randInt(8, 15);
        let n = randInt(3, 8);
        let A = P * Math.pow(1 - r / 100, n);
        let q = `A car valued at R${P} depreciates on the reducing balance method at ${r}% p.a. Calculate its value after ${n} years. (Round to nearest integer)`;

        let correct = `R${Math.round(A)}`;
        let wrong1 = `R${Math.round(P * (1 - (r / 100) * n))}`; // Straight line
        let wrong2 = `R${Math.round(P * Math.pow(1 + r / 100, n))}`; // Compound growth
        let wrong3 = `R${Math.round(A * 0.9)}`;

        createQuestion('finance', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Use the reducing balance formula: \\(A = P(1 - i)^n\\)`,
            `\\(P = ${P}\\), \\(i = ${r}/100 = ${r / 100}\\), \\(n = ${n}\\)`,
            `\\(A = ${P}(1 - ${r / 100})^{${n}}\\)`,
            `\\(A \\approx ${Math.round(A)}\\)`
        ]);
    }

    // Effective Interest Rate
    for (let i = 0; i < 5; i++) {
        let rNom = randInt(6, 12);
        let iNom = rNom / 100;
        let eff = Math.pow(1 + iNom / 12, 12) - 1;
        let effPerc = (eff * 100).toFixed(2);

        let q = `Convert a nominal interest rate of ${rNom}% p.a. compounded monthly to an effective annual rate.`;
        let correct = `${effPerc}%`;
        let wrong1 = `${rNom}%`;
        let wrong2 = `${(rNom + 0.5).toFixed(2)}%`;
        let wrong3 = `${(rNom * 1.1).toFixed(2)}%`;

        createQuestion('finance', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Formula: \\(1 + i_{eff} = (1 + \\frac{i_{nom}}{m})^m\\)`,
            `\\(1 + i_{eff} = (1 + \\frac{${iNom}}{12})^{12}\\)`,
            `\\(i_{eff} = (1 + \\frac{${iNom}}{12})^{12} - 1 = ${eff.toFixed(4)}\\)`,
            `Multiply by 100: ${effPerc}%`
        ]);
    }

    // Future Value Annuity
    for (let i = 0; i < 5; i++) {
        let x = randInt(5, 15) * 100;
        let r = randInt(8, 12);
        let years = randInt(5, 10);
        let n = years * 12;
        let iMonthly = r / 100 / 12;
        let F = x * (Math.pow(1 + iMonthly, n) - 1) / iMonthly;

        let q = `Thabo deposits R${x} at the end of every month into an account earning ${r}% p.a. compounded monthly. How much will he have after ${years} years?`;
        let correct = `R${F.toFixed(2)}`;
        let wrong1 = `R${(F * 0.8).toFixed(2)}`;
        let wrong2 = `R${(x * 12 * years).toFixed(2)}`;
        let wrong3 = `R${(F * 1.2).toFixed(2)}`;

        createQuestion('finance', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Use the Future Value Annuity formula: \\(F = \\dfrac{x[(1+i)^n - 1]}{i}\\)`,
            `\\(x = ${x}\\), \\(i = ${r / 100}/12\\), \\(n = ${years} \\times 12 = ${n}\\)`,
            `\\(F = \\dfrac{${x}[(1+${(r / 100 / 12).toFixed(4)})^{${n}} - 1]}{${(r / 100 / 12).toFixed(4)}}\\)`,
            `\\(F = R${F.toFixed(2)}\\)`
        ]);
    }
}

// 6. PROBABILITY
function generateProbability() {
    for (let i = 0; i < 5; i++) {
        let pa = (randInt(2, 6) / 10).toFixed(1);
        let pb = (randInt(2, 6) / 10).toFixed(1);
        let intersection = (pa * pb).toFixed(2);

        let q = `Events A and B are independent. If \\(P(A) = ${pa}\\) and \\(P(B) = ${pb}\\), calculate \\(P(A \\text{ and } B)\\).`;
        let correct = `\\(${intersection}\\)`;
        let wrong1 = `\\(${(parseFloat(pa) + parseFloat(pb)).toFixed(1)}\\)`;
        let wrong2 = `\\(1\\)`;
        let wrong3 = `\\(0\\)`; // Mutually exclusive trap

        createQuestion('probability', q, [correct, wrong1, wrong2, wrong3], 0, [
            `For independent events: \\(P(A \\text{ and } B) = P(A) \\times P(B)\\)`,
            `\\(P(A \\text{ and } B) = ${pa} \\times ${pb} = ${intersection}\\)`
        ]);
    }

    // Counting Principle (Words)
    for (let i = 0; i < 5; i++) {
        const words = ['MATA', 'DATA', 'BASE', 'CELL'];
        const word = words[i % 4];
        let n = word.length; // 4
        // Calculate permutations with repetitions manually
        let counts = {};
        for (let char of word) { counts[char] = (counts[char] || 0) + 1; }

        let denomDiv = 1;
        let denomStr = "";
        for (let char in counts) {
            if (counts[char] > 1) {
                let fact = 1;
                for (let k = 1; k <= counts[char]; k++) fact *= k;
                denomDiv *= fact;
                denomStr += `${counts[char]}!`;
            }
        }

        let totalWays = 24 / denomDiv; // 4! is 24

        let q = `How many unique 4-letter arrangements can be made using the letters of the word '${word}'?`;
        let correct = `${totalWays}`;
        let wrong1 = `24`; // Assuming no reps
        let wrong2 = `${totalWays * 2}`;
        let wrong3 = `${totalWays + 4}`;

        createQuestion('probability', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Total letters: ${n} (Numerator = ${n}!)`,
            denomStr ? `Repeated letters: ${denomStr} (Denominator)` : `No repeated letters.`,
            `Total arrangements = \\(\\dfrac{${n}!}{${denomStr || '1'}} = ${totalWays}\\)`
        ]);
    }
}

// 7. TRIGONOMETRY
function generateTrig() {
    // Reduction Formula
    for (let i = 0; i < 5; i++) {
        let q = `Simplify: \\(\\dfrac{\\sin(180^\\circ + \\theta) \\cdot \\cos(90^\\circ + \\theta)}{\\cos(360^\\circ - \\theta)}\\)`;
        let correct = `\\(\\dfrac{\\sin^2 \\theta}{\\cos \\theta}\\)`;
        let wrong1 = `\\(\\tan \\theta\\)`;
        let wrong2 = `\\(-\\tan \\theta\\)`;
        let wrong3 = `\\(-\\sin \\theta\\)`;

        createQuestion('trigonometry', q, [correct, wrong1, wrong2, wrong3], 0, [
            `\\(\\sin(180^\\circ + \\theta)\\) is in 3rd quadrant (sine is negative) \\(\\rightarrow -\\sin \\theta\\)`,
            `\\(\\cos(90^\\circ + \\theta)\\) is in 2nd quadrant (cosine is negative, co-ratio) \\(\\rightarrow -\\sin \\theta\\)`,
            `\\(\\cos(360^\\circ - \\theta)\\) is in 4th quadrant (cosine is positive) \\(\\rightarrow \\cos \\theta\\)`,
            `\\(\\dfrac{(-\\sin \\theta)(-\\sin \\theta)}{\\cos \\theta} = \\dfrac{\\sin^2 \\theta}{\\cos \\theta}\\)`
        ]);
    }

    // Identities
    for (let i = 0; i < 5; i++) {
        let q = `Simplify: \\(\\sin 2x \\cdot \\tan x\\) entirely in terms of sine and cosine.`;
        let correct = `\\(2\\sin^2 x\\)`;
        let wrong1 = `\\(2\\cos^2 x\\)`;
        let wrong2 = `\\(\\sin x \\cos x\\)`;
        let wrong3 = `\\(1\\)`;

        createQuestion('trigonometry', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Double angle identity: \\(\\sin 2x = 2\\sin x \\cos x\\)`,
            `Quotient identity: \\(\\tan x = \\dfrac{\\sin x}{\\cos x}\\)`,
            `\\(2\\sin x \\cos x \\cdot \\dfrac{\\sin x}{\\cos x}\\)`,
            `Cosine terms cancel: \\(2\\sin^2 x\\)`
        ]);
    }

    // Equations
    for (let i = 0; i < 5; i++) {
        let q = `Determine the reference angle for the equation: \\(2\\cos \\theta = 1\\)`;
        let correct = `\\(60^\\circ\\)`;
        let wrong1 = `\\(30^\\circ\\)`;
        let wrong2 = `\\(45^\\circ\\)`;
        let wrong3 = `\\(120^\\circ\\)`;

        createQuestion('trigonometry', q, [correct, wrong1, wrong2, wrong3], 0, [
            `Isolate the trig ratio: \\(\\cos \\theta = \\dfrac{1}{2}\\)`,
            `Reference angle = \\(\\cos^{-1}(0.5) = 60^\\circ\\)`
        ]);
    }
}

// 8. GEOMETRY (Euclidean)
function generateGeometry() {
    for (let i = 0; i < 15; i++) {
        let angles = [
            "Angle at centre = 2 × angle at circumference",
            "Angles in same segment are equal",
            "Opposite angles of cyclic quad sum to 180°",
            "Exterior angle of cyclic quad = interior opposite angle",
            "Tan-chord theorem"
        ];
        let theorem = angles[randInt(0, 4)];
        let q = `Which Euclidean Geometry theorem states exactly this: "${theorem}"?`;

        let shuffled = [...angles].sort(() => 0.5 - Math.random());
        // Simple mock question for theory reinforcement
        createQuestion('geometry', q, shuffled.slice(0, 4), shuffled.slice(0, 4).indexOf(theorem) > -1 ? shuffled.slice(0, 4).indexOf(theorem) : 0, [
            `This is standard Euclidean geometry theory.`,
            `The correct theorem name/description is "${theorem}".`
        ]);
        // Note: For a real app, dynamic image-based geometry questions are best, but text-based theory is a good stopgap.
    }
}


// --------------------------------------------------------------------------
// EXECUTION
// --------------------------------------------------------------------------

// Read existing questions so we don't delete them
function generateAllQuestions(options = {}) {
    questions = []; // Reset for each run
    const topicFilter = options.topic || 'all';

    const generators = {
        'algebra': generateAlgebra,
        'patterns': generatePatterns,
        'functions': generateFunctions,
        'calculus': generateCalculus,
        'finance': generateFinance,
        'probability': generateProbability,
        'trigonometry': generateTrig,
        'geometry': generateGeometry
    };

    if (topicFilter === 'all') {
        generateAlgebra();
        generatePatterns();
        generateFunctions();
        generateCalculus();
        generateFinance();
        generateProbability();
        generateTrig();
        generateGeometry();
    } else if (generators[topicFilter]) {
        generators[topicFilter]();
    }

    const filePath = path.join(__dirname, 'public', 'js', 'questions.json');
    let existingQuestions = [];

    if (fs.existsSync(filePath)) {
        const data = fs.readFileSync(filePath, 'utf8');
        try {
            existingQuestions = JSON.parse(data);
        } catch (e) {
            console.error("Error parsing existing json, starting fresh.");
        }
    }

    const allQuestions = [...existingQuestions, ...questions];
    fs.writeFileSync(filePath, JSON.stringify(allQuestions, null, 2), 'utf8');

    return {
        newCount: questions.length,
        totalCount: allQuestions.length
    };
}

module.exports = { generateAllQuestions };

if (require.main === module) {
    const result = generateAllQuestions();
    console.log(`Successfully generated and appended ${result.newCount} new questions.`);
    console.log(`Total questions in database: ${result.totalCount}`);
}
