/**
 * masterclass-data.js
 * Contains model questions with "Examiner's Notes" for the Mastery Workshop.
 * 3 questions per major topic.
 */

const masterclassData = {
    algebra: [
        {
            title: "Solving for x using the Quadratic Formula",
            question: "Solve for \\(x\\): \\( 2x^2 - 5x - 3 = 0 \\)",
            steps: [
                { tex: "a = 2, \\quad b = -5, \\quad c = -3", note: "Standard form is \\(ax^2 + bx + c = 0\\). Watch the signs!" },
                { tex: "x = \\frac{-(-5) \\pm \\sqrt{(-5)^2 - 4(2)(-3)}}{2(2)}", note: "Substitute carefully. Note that \\((-5)^2\\) is positive 25." },
                { tex: "x = \\frac{5 \\pm \\sqrt{25 + 24}}{4} = \\frac{5 \\pm \\sqrt{49}}{4}", note: "\\(\\Delta = 49\\) is a perfect square, so the roots will be rational." },
                { tex: "x = \\frac{12}{4} = 3 \\quad \\text{or} \\quad x = \\frac{-2}{4} = -0,5", note: "Always give both solutions unless stated otherwise." }
            ]
        },
        {
            title: "Simultaneous Equations (Quadratic & Linear)",
            question: "Solve for \\(x\\) and \\(y\\): \\( y = x + 2 \\) and \\( x^2 + y^2 = 20 \\)",
            steps: [
                { tex: "x^2 + (x+2)^2 = 20", note: "Substitute the linear into the quadratic. Don't forget to expand the bracket properly!" },
                { tex: "x^2 + x^2 + 4x + 4 = 20 \\implies 2x^2 + 4x - 16 = 0", note: "Bring everything to one side to get standard form." },
                { tex: "x^2 + 2x - 8 = 0 \\implies (x+4)(x-2) = 0", note: "Divide by 2 first to make factoring easier." },
                { tex: "x = -4 \\implies y = -2; \\quad x = 2 \\implies y = 4", note: "Pair your answers! \\((-4; -2)\\) and \\((2; 4)\\)." }
            ]
        },
        {
            title: "Inequalities with Intervals",
            question: "Solve for \\(x\\): \\( x^2 - x - 6 < 0 \\)",
            steps: [
                { tex: "(x-3)(x+2) < 0", note: "Start by finding the critical values (CV) by factoring." },
                { tex: "CV: x = 3; \\quad x = -2", note: "These are the boundaries where the graph crosses the x-axis." },
                { tex: "-2 < x < 3", note: "Since the parabola is concave up and we want 'less than zero', we take the 'valley' between the roots." }
            ]
        }
    ],
    functions: [
        {
            title: "Finding the Equation of a Hyperbola",
            question: "Find \\(q\\) and \\(a\\) for \\( f(x) = \\frac{a}{x-1} + q \\) passing through \\( (2; 5) \\) with asymptote \\( y = 2 \\).",
            steps: [
                { tex: "q = 2", note: "The horizontal asymptote is always the value of \\(q\\)." },
                { tex: "5 = \\frac{a}{2-1} + 2", note: "Substitute the point (2; 5) into the equation." },
                { tex: "3 = \\frac{a}{1} \\implies a = 3", note: "Solve the linear equation for \\(a\\)." },
                { tex: "f(x) = \\frac{3}{x-1} + 2", note: "State the final equation clearly." }
            ]
        },
        {
            title: "Inverse of an Exponential Function",
            question: "Find the inverse of \\( f(x) = 3^x \\).",
            steps: [
                { tex: "x = 3^y", note: "Swap \\(x\\) and \\(y\\) to find the inverse relationship." },
                { tex: "y = \\log_3 x", note: "Use the log definition: if \\(x = b^y\\) then \\(y = \\log_b x\\)." },
                { tex: "f^{-1}(x) = \\log_3 x", note: "Rename the result using inverse notation." }
            ]
        },
        {
            title: "Determining Nature of Roots",
            question: "For what values of \\(k\\) does \\( x^2 - 4x + k = 0 \\) have non-real roots?",
            steps: [
                { tex: "\\Delta < 0", note: "Condition for non-real (imaginary) roots is a negative discriminant." },
                { tex: "(-4)^2 - 4(1)(k) < 0", note: "Substitute into \\(b^2 - 4ac\\)." },
                { tex: "16 - 4k < 0 \\implies 16 < 4k", note: "Solve the linear inequality." },
                { tex: "k > 4", note: "If \\(k\\) is greater than 4, the parabola stays entirely above the x-axis." }
            ]
        }
    ],
    trigonometry: [
        {
            title: "Simplifying with Compound Angles",
            question: "Simplify: \\( \\cos(x - 30^\\circ) - \\cos(x + 30^\\circ) \\)",
            steps: [
                { tex: "(\\cos x \\cos 30 + \\sin x \\sin 30) - ( \\cos x \\cos 30 - \\sin x \\sin 30)", note: "Expand both parts using compound angle identities." },
                { tex: "\\cos x \\cos 30 + \\sin x \\sin 30 -  \\cos x \\cos 30 + \\sin x \\sin 30", note: "Watch the sign change when subtracting the second bracket!" },
                { tex: "2\\sin x \\sin 30", note: "The cosine terms cancel out." },
                { tex: "2\\sin x (0,5) = \\sin x", note: "Substitute special angle values to reach the simplest form." }
            ]
        },
        {
            title: "Solving General Solution",
            question: "Find the general solution of \\( 2\\sin^2 \\theta = \\sin \\theta \\).",
            steps: [
                { tex: "2\\sin^2 \\theta - \\sin \\theta = 0 \\implies \\sin \\theta(2\\sin \\theta - 1) = 0", note: "DO NOT divide by \\(\\sin \\theta\\)! Always factorize to keep all solutions." },
                { tex: "\\sin \\theta = 0 \\quad \\text{or} \\quad \\sin \\theta = 0,5", note: "Solve each factor separately." },
                { tex: "\\theta = 180^\\circ \\cdot k \\quad (k \\in \\mathbb{Z})", note: "General solution for sine being zero." },
                { tex: "\\theta = 30^\\circ + 360^\\circ k \\quad \\text{or} \\quad \\theta = 150^\\circ + 360^\\circ k", note: "General solution for sine being 0,5." }
            ]
        },
        {
            title: "Trig Proof with Identities",
            question: "Prove: \\( \\frac{\\sin 2\\alpha}{1 + \\cos 2\\alpha} = \\tan \\alpha \\)",
            steps: [
                { tex: "LHS = \\frac{2\\sin \\alpha \\cos \\alpha}{1 + (2\\cos^2 \\alpha - 1)}", note: "Double angle sine has 1 form. For cosine, pick the one that cancels the '+1'." },
                { tex: "\\frac{2\\sin \\alpha \\cos \\alpha}{2\\cos^2 \\alpha}", note: "Simplify the denominator. The '1's cancel out." },
                { tex: "\\frac{\\sin \\alpha}{\\cos \\alpha} = \\tan \\alpha", note: "Divide by common factor \\(2\\cos \\alpha\\) to reach RHS." }
            ]
        }
    ],
    calculus: [
        {
            title: "Derivative from First Principles",
            question: "Find \\( f'(x) \\) if \\( f(x) = 2x^2 \\) using first principles.",
            steps: [
                { tex: "f(x+h) = 2(x+h)^2 = 2x^2 + 4xh + 2h^2", note: "First, find and expand \\(f(x+h)\\)." },
                { tex: "\\lim_{h \\to 0} \\frac{(2x^2 + 4xh + 2h^2) - (2x^2)}{h}", note: "Substitute into the limit definition formula." },
                { tex: "\\lim_{h \\to 0} \\frac{4xh + 2h^2}{h} = \\lim_{h \\to 0} (4x + 2h)", note: "Factorize \\(h\\) out and cancel it with the denominator." },
                { tex: "f'(x) = 4x", note: "Let \\(h = 0\\). You can check this using power rules!" }
            ]
        },
        {
            title: "Finding Equations of Tangents",
            question: "Find equation of tangent to \\( f(x) = x^2 - 4 \\) at \\( x = 3 \\).",
            steps: [
                { tex: "f(3) = (3)^2 - 4 = 5", note: "Find the y-coordinate of the point (3; 5)." },
                { tex: "f'(x) = 2x \\implies f'(3) = 6", note: "Differentiate and substitute x=3 to find the gradient \\(m\\)." },
                { tex: "y - 5 = 6(x - 3)", note: "Use the point-gradient form of a straight line." },
                { tex: "y = 6x - 13", note: "Expand and simplify to standard line form." }
            ]
        },
        {
            title: "Optimization (Cubic Maximum)",
            question: "A company's profit is \\( P(x) = -x^3 + 300x \\). Find the value of \\(x\\) for max profit.",
            steps: [
                { tex: "P'(x) = -3x^2 + 300", note: "At a maximum, the rate of change is zero." },
                { tex: "-3x^2 + 300 = 0 \\implies x^2 = 100", note: "Set the derivative to zero and solve for \\(x\\)." },
                { tex: "x = 10", note: "We ignore \\(x = -10\\) as it's impossible in this context." },
                { tex: "10 \\text{ units}", note: "Maximum profit occurs when 10 units are produced." }
            ]
        }
    ]
};
