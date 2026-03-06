const examinerData = [
    {
        id: "alg_1",
        topic: "Algebra & Equations",
        question: "Solve for \\(x\\): \\( x^2 - 5x + 6 = 0 \\)",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "x^2 - 5x + 6 = 0" },
            { id: 1, tex: "(x - 2)(x + 3) = 0" },
            { id: 2, tex: "x = 2 \\text{ or } x = -3" }
        ],
        incorrectStepId: 1,
        explanation: "The factors of \\(+6\\) that add up to \\(-5\\) are \\(-2\\) and \\(-3\\). The correct factorization is \\((x - 2)(x - 3) = 0\\)."
    },
    {
        id: "calc_1",
        topic: "Calculus",
        question: "Find \\( \\frac{dy}{dx} \\) if \\( y = 3x^4 - \\frac{2}{x^2} \\)",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "y = 3x^4 - 2x^{-2}" },
            { id: 1, tex: "\\frac{dy}{dx} = 12x^3 - 4x^{-3}" },
            { id: 2, tex: "\\frac{dy}{dx} = 12x^3 - \\frac{4}{x^3}" }
        ],
        incorrectStepId: 1,
        explanation: "When applying the power rule to \\(-2x^{-2}\\), you bring down the \\(-2\\) and multiply: \\(-2 \\times -2 = +4\\). The power becomes \\(-2 - 1 = -3\\). The correct derivative is \\(12x^3 + 4x^{-3}\\)."
    },
    {
        id: "trig_1",
        topic: "Trigonometry",
        question: "Simplify: \\( \\frac{\\sin(180^\\circ - \\theta)\\cos(360^\\circ - \\theta)}{\\tan(180^\\circ + \\theta)} \\)",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "\\frac{(\\sin \\theta)(\\cos \\theta)}{\\tan \\theta}" },
            { id: 1, tex: "\\frac{\\sin \\theta \\cos \\theta}{\\frac{\\cos \\theta}{\\sin \\theta}}" },
            { id: 2, tex: "\\sin \\theta \\cos \\theta \\times \\frac{\\sin \\theta}{\\cos \\theta}" },
            { id: 3, tex: "\\sin^2 \\theta" }
        ],
        incorrectStepId: 1,
        explanation: "The quotient identity for tangent is \\(\\tan \\theta = \\frac{\\sin \\theta}{\\cos \\theta}\\), not \\(\\frac{\\cos \\theta}{\\sin \\theta}\\) (which is cotangent)."
    },
    {
        id: "seq_1",
        topic: "Number Patterns",
        question: "Given the arithmetic sequence: 5; 9; 13; 17; ... Find the 50th term.",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "a = 5, \\quad d = 9 - 5 = 4" },
            { id: 1, tex: "T_n = a + (n-1)d" },
            { id: 2, tex: "T_{50} = 5 + (50)4" },
            { id: 3, tex: "T_{50} = 5 + 200 = 205" }
        ],
        incorrectStepId: 2,
        explanation: "The formula is \\(a + (n-1)d\\). When substituting \\(n = 50\\), the term inside the parenthesis should be \\((50 - 1) = 49\\), not \\(50\\). The correct step is \\(T_{50} = 5 + (49)4\\)."
    },
    {
        id: "alg_2",
        topic: "Algebra & Equations",
        question: "Solve for \\(x\\): \\( \\sqrt{x-2} = x - 4 \\)",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "(\\sqrt{x-2})^2 = (x - 4)^2" },
            { id: 1, tex: "x - 2 = x^2 - 16" },
            { id: 2, tex: "0 = x^2 - x - 14" }
        ],
        incorrectStepId: 1,
        explanation: "When squaring a binomial like \\((x - 4)^2\\), you must use FOIL. The middle term is missing. The correct expansion is \\(x^2 - 8x + 16\\)."
    },
    {
        id: "fin_1",
        topic: "Finance",
        question: "Sipho deposits R500 at the end of every month into an account earning 8% p.a. compounded monthly. How much is in the account after 5 years?",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "x = 500; \\quad i = \\frac{0.08}{12}; \\quad n = 5 \\times 12 = 60" },
            { id: 1, tex: "F = \\frac{x[(1+i)^n - 1]}{i}" },
            { id: 2, tex: "F = \\frac{500[1 - (1+\\frac{0.08}{12})^{-60}]}{\\frac{0.08}{12}}" }
        ],
        incorrectStepId: 2,
        explanation: "The student substituted into the Present Value (\\(P\\)) formula instead of the Future Value (\\(F\\)) formula. The question asks 'How much is in the account after' which indicates a future savings goal."
    },
    {
        id: "calc_2",
        topic: "Calculus",
        question: "Find the minimum value of \\( f(x) = x^2 - 6x + 5 \\).",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "f'(x) = 2x - 6" },
            { id: 1, tex: "2x - 6 = 0 \\implies x = 3" },
            { id: 2, tex: "\\text{Minimum value is } 3" }
        ],
        incorrectStepId: 2,
        explanation: "The **Independent Variable Trap**. The value \\(x = 3\\) is where the minimum occurs, but the minimum *value* is the y-coordinate. They should have calculated \\(f(3) = (3)^2 - 6(3) + 5 = -4\\)."
    },
    {
        id: "trig_2",
        topic: "Trigonometry",
        question: "Solve for \\(\\theta\\) if \\( 2\\sin \\theta = 1 \\) for \\( \\theta \\in [0^\\circ; 360^\\circ] \\).",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "\\sin \\theta = 0,5" },
            { id: 1, tex: "\\text{ref angle} = 30^\\circ" },
            { id: 2, tex: "\\theta = 30^\\circ \\text{ or } \\theta = 210^\\circ" }
        ],
        incorrectStepId: 2,
        explanation: "The **Quadrant Confusion Trap**. Sine is positive in the 1st and 2nd quadrants. The second solution should be \\(180^\\circ - 30^\\circ = 150^\\circ\\), not the 3rd quadrant value."
    },
    {
        id: "geo_1",
        topic: "Euclidean Geometry",
        question: "In circle O, chord AB is perpendicular to radius OT at M. If AB = 8 and OM = 3, find the radius r.",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "\\text{Since } AB \\perp OT, \\text{ then } AM = MB = 4" },
            { id: 1, tex: "r^2 = 8^2 + 3^2" },
            { id: 2, tex: "r^2 = 64 + 9 = 73 \\implies r = \\sqrt{73}" }
        ],
        incorrectStepId: 1,
        explanation: "The **Hypotenuse Trap**. In the right-angled triangle OMA, the sides are AM=4 and OM=3. Pythagoras states \\(r^2 = 4^2 + 3^2 = 25\\), so \\(r=5\\). They used the full chord length instead of the halved segment."
    },
    {
        id: "alg_3",
        topic: "Algebra",
        question: "Solve for \\(x\\): \\( 2(x-3)^2 = 18 \\)",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "(2x - 6)^2 = 18" },
            { id: 1, tex: "4x^2 - 24x + 36 = 18" },
            { id: 2, tex: "4x^2 - 24x + 18 = 0" }
        ],
        incorrectStepId: 0,
        explanation: "The **Order of Operations Trap**. You cannot distribute a constant into a bracket that is being squared. The correct move is to divide by 2 first: \\((x-3)^2 = 9\\)."
    },
    {
        id: "seq_2",
        topic: "Number Patterns",
        question: "Find the sum of the series: \\( \\sum_{k=1}^{10} (3k + 2) \\)",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "a = 3(1) + 2 = 5; \\quad l = 3(10) + 2 = 32" },
            { id: 1, tex: "n = 10 - 1 = 9" },
            { id: 2, tex: "S_{n} = \\frac{9}{2}(5 + 32) = 166,5" }
        ],
        incorrectStepId: 1,
        explanation: "The **Off-by-One Sigma Trap**. For a sum from \\(k=1\\) to \\(10\\), the number of terms is \\(10 - 1 + 1 = 10\\). They forgot to add the 1 back."
    },
    {
        id: "stats_1",
        topic: "Statistics",
        question: "Find the standard deviation of: 2, 4, 6, 8, 10 (Mean is 6).",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "\\text{Variance } \\sigma^2 = \\frac{(2-6)^2 + (4-6)^2 + (6-6)^2 + (8-6)^2 + (10-6)^2}{5}" },
            { id: 1, tex: "\\sigma^2 = \\frac{16 + 4 + 0 + 4 + 16}{5} = 8" },
            { id: 2, tex: "\\text{Standard Deviation } \\sigma = 64" }
        ],
        incorrectStepId: 2,
        explanation: "The **Square vs Square Root Trap**. Standard deviation is the square root of variance, not the square. The correct answer is \\(\\sqrt{8} \\approx 2,83\\)."
    },
    {
        id: "prob_1",
        topic: "Probability",
        question: "How many ways can the letters in 'REED' be arranged?",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "\\text{Total letters} = 4" },
            { id: 1, tex: "\\text{Arrangements} = 4! = 24" }
        ],
        incorrectStepId: 1,
        explanation: "The **Identical Items Trap**. Since there are two 'E's, we must divide by 2! to account for identical arrangements. The correct answer is \\(4! / 2! = 12\\)."
    },
    {
        id: "calc_3",
        topic: "Calculus",
        question: "Find the equation of the tangent to \\( f(x) = x^2 \\) at \\( x = 3 \\).",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "f'(x) = 2x \\implies f'(3) = 6" },
            { id: 1, tex: "y = 6x + c" },
            { id: 2, tex: "3 = 6(3) + c \\implies c = -15" }
        ],
        incorrectStepId: 2,
        explanation: "The **Coordinate Swap Trap**. They substituted the x-value (3) into the y-position of the line equation. They should first find \\(f(3) = 9\\), then use the point (3; 9)."
    },
    {
        id: "trig_3",
        topic: "Trigonometry",
        question: "Prove that \\( \\frac{\\cos 2A}{\\cos A - \\sin A} = \\cos A + \\sin A \\)",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "\\frac{2\\cos^2 A - 1}{\\cos A - \\sin A}" },
            { id: 1, tex: "\\frac{(\\cos A - \\sin A)(\\cos A + \\sin A)}{\\cos A - \\sin A}" },
            { id: 2, tex: "\\cos A + \\sin A" }
        ],
        incorrectStepId: 0,
        explanation: "The **Dead-End Identity Trap**. While \\(\\cos 2A = 2\\cos^2 A - 1\\) is true, it doesn't help with the cancelation. They should use \\(\\cos^2 A - \\sin^2 A\\) in Step 1 to make Step 2 possible."
    },
    {
        id: "fin_2",
        topic: "Finance",
        question: "An investment earns 12% p.a. compounded quarterly. Find the effective annual rate.",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "1 + i_{eff} = (1 + \\frac{0,12}{12})^{12}" },
            { id: 1, tex: "1 + i_{eff} = (1,01)^{12} = 1,1268" },
            { id: 2, tex: "i_{eff} = 12,68\\%" }
        ],
        incorrectStepId: 0,
        explanation: "The **Compounding Period Trap**. The question said 'quarterly' (m=4), but the student used monthly compounding (m=12) in the formula."
    },
    {
        id: "alg_4",
        topic: "Algebra",
        question: "Solve for \\(x\\): \\( x(x-3) > 4 \\)",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "x > 4 \\text{ or } x-3 > 4" },
            { id: 1, tex: "x > 4 \\text{ or } x > 7" }
        ],
        incorrectStepId: 0,
        explanation: "The **Inequality Logic Trap**. You cannot split a quadratic inequality like a linear equation. You must set it to zero: \\(x^2 - 3x - 4 > 0\\), find critical values, and test intervals."
    },
    {
        id: "seq_3",
        topic: "Number Patterns",
        question: "Find the missing term in the quadratic sequence: 2; 5; 10; 17; ...",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "\\text{First diffs: } 3, 5, 7" },
            { id: 1, tex: "\\text{Second diff: } 2" },
            { id: 2, tex: "\\text{Next first diff: } 7 + 2 = 8" }
        ],
        incorrectStepId: 2,
        explanation: "The **Basic Arithmetic Trap**. \\(7 + 2\\) is \\(9\\), not \\(8\\). A small mental slip in the heat of a marking session!"
    },
    {
        id: "geo_2",
        topic: "Euclidean Geometry",
        question: "Prove that the sum of the opposite angles of a cyclic quadrilateral is 180°.",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "\\hat{A} + \\hat{C} = 180^\\circ" },
            { id: 1, tex: "\\text{Reasons: Angles in the same segment}" }
        ],
        incorrectStepId: 1,
        explanation: "The **Generic Reason Trap**. 'Angles in the same segment' is used for angles subtended by a chord. The cyclic quad proof requires 'Arcs subtend angles at center' or the theorem of cyclic quads. 'Angles in same segment' implies they are equal, not supplementary."
    },
    {
        id: "analyt_1",
        topic: "Analytical Geometry",
        question: "Find the gradient of the line perpendicular to \\( 2y + 4x = 8 \\).",
        difficulty: "Medium",
        steps: [
            { id: 0, tex: "2y = -4x + 8 \\implies y = -2x + 4" },
            { id: 1, tex: "m_1 = -2" },
            { id: 2, tex: "m_{perp} = 2" }
        ],
        incorrectStepId: 2,
        explanation: "The **Negative Reciprocal Trap**. Perpendicular gradients multiply to -1. The student just changed the sign but didn't flip the fraction. The gradient should be \\(+1/2\\)."
    },
    {
        id: "trig_4",
        topic: "Trigonometry",
        question: "Determine the value of \\( \\cos(-210^\\circ) \\) without a calculator.",
        difficulty: "Hard",
        steps: [
            { id: 0, tex: "\\cos(-210^\\circ) = \\cos(210^\\circ)" },
            { id: 1, tex: "\\cos(210^\\circ) = \\cos(180^\\circ - 30^\\circ)" },
            { id: 2, tex: "= -\\cos 30^\\circ = -\\frac{\\sqrt{3}}{2}" }
        ],
        incorrectStepId: 1,
        explanation: "The **Reduction Expansion Trap**. \\(210^\\circ\\) is in the 3rd quadrant. It should be reduced as \\(180^\\circ + 30^\\circ\\). Using \\(180^\\circ - 30^\\circ\\) would give \\(150^\\circ\\) (2nd quadrant)."
    },
    {
        id: "stats_2",
        topic: "Statistics",
        question: "Calculate the median of the following set: 10, 5, 12, 8, 3",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "\\text{The middle number is } 12" }
        ],
        incorrectStepId: 0,
        explanation: "The **Unsorted Data Trap**. You must always arrange the data in ascending order (3, 5, 8, 10, 12) before finding the middle term (8)."
    },
    {
        id: "prob_2",
        topic: "Probability",
        question: "Find \\( P(A \\text{ or } B) \\) if \\( P(A)=0,3, P(B)=0,4 \\) and events are mutually exclusive.",
        difficulty: "Easy",
        steps: [
            { id: 0, tex: "P(A \\cup B) = P(A) \\times P(B)" },
            { id: 1, tex: "P(A \\cup B) = 0,12" }
        ],
        incorrectStepId: 0,
        explanation: "The **And vs Or Trap**. For mutually exclusive events, OR $(\cup)$ means addition, not multiplication. Multiplication is for independent AND $(\cap)$ events."
    }
];

// If using Node or modules (optional for web, but good practice):
if (typeof module !== 'undefined' && module.exports) {
    module.exports = examinerData;
}
window.examinerData = examinerData;
