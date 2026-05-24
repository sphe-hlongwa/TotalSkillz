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
                { tex: "\\( a = 2, \\quad b = -5, \\quad c = -3 \\)", note: "Standard form is \\(ax^2 + bx + c = 0\\). Watch the signs!" },
                { tex: "\\( x = \\frac{-(-5) \\pm \\sqrt{(-5)^2 - 4(2)(-3)}}{2(2)} \\)", note: "Substitute carefully. Note that \\((-5)^2\\) is positive 25." },
                { tex: "\\( x = \\frac{5 \\pm \\sqrt{25 + 24}}{4} = \\frac{5 \\pm \\sqrt{49}}{4} \\)", note: "\\(\\Delta = 49\\) is a perfect square, so the roots will be rational." },
                { tex: "\\( x = \\frac{12}{4} = 3 \\quad \\text{or} \\quad x = \\frac{-2}{4} = -0,5 \\)", note: "Always give both solutions unless stated otherwise." }
            ]
        },
        {
            title: "Simultaneous Equations (Quadratic & Linear)",
            question: "Solve for \\(x\\) and \\(y\\): \\( y = x + 2 \\) and \\( x^2 + y^2 = 20 \\)",
            steps: [
                { tex: "\\( x^2 + (x+2)^2 = 20 \\)", note: "Substitute the linear into the quadratic. Don't forget to expand the bracket properly!" },
                { tex: "\\( x^2 + x^2 + 4x + 4 = 20 \\implies 2x^2 + 4x - 16 = 0 \\)", note: "Bring everything to one side to get standard form." },
                { tex: "\\( x^2 + 2x - 8 = 0 \\implies (x+4)(x-2) = 0 \\)", note: "Divide by 2 first to make factoring easier." },
                { tex: "\\( x = -4 \\implies y = -2; \\quad x = 2 \\implies y = 4 \\)", note: "Pair your answers! \\((-4; -2)\\) and \\((2; 4)\\)." }
            ]
        },
        {
            title: "Inequalities with Intervals",
            question: "Solve for \\(x\\): \\( x^2 - x - 6 < 0 \\)",
            steps: [
                { tex: "\\( (x-3)(x+2) < 0 \\)", note: "Start by finding the critical values (CV) by factoring." },
                { tex: "\\( CV: x = 3; \\quad x = -2 \\)", note: "These are the boundaries where the graph crosses the x-axis." },
                { tex: "\\( -2 < x < 3 \\)", note: "Since the parabola is concave up and we want 'less than zero', we take the 'valley' between the roots." }
            ]
        }
    ],
    functions: [
        {
            title: "Finding the Equation of a Hyperbola",
            question: "Find \\(q\\) and \\(a\\) for \\( f(x) = \\frac{a}{x-1} + q \\) passing through \\( (2; 5) \\) with asymptote \\( y = 2 \\).",
            steps: [
                { tex: "\\( q = 2 \\)", note: "The horizontal asymptote is always the value of \\(q\\)." },
                { tex: "\\( 5 = \\frac{a}{2-1} + 2 \\)", note: "Substitute the point (2; 5) into the equation." },
                { tex: "\\( 3 = \\frac{a}{1} \\implies a = 3 \\)", note: "Solve the linear equation for \\(a\\)." },
                { tex: "\\( f(x) = \\frac{3}{x-1} + 2 \\)", note: "State the final equation clearly." }
            ]
        },
        {
            title: "Inverse of an Exponential Function",
            question: "Find the inverse of \\( f(x) = 3^x \\).",
            steps: [
                { tex: "\\( x = 3^y \\)", note: "Swap \\(x\\) and \\(y\\) to find the inverse relationship." },
                { tex: "\\( y = \\log_3 x \\)", note: "Use the log definition: if \\(x = b^y\\) then \\(y = \\log_b x\\)." },
                { tex: "\\( f^{-1}(x) = \\log_3 x \\)", note: "Rename the result using inverse notation." }
            ]
        },
        {
            title: "Determining Nature of Roots",
            question: "For what values of \\(k\\) does \\( x^2 - 4x + k = 0 \\) have non-real roots?",
            steps: [
                { tex: "\\( \\Delta < 0 \\)", note: "Condition for non-real (imaginary) roots is a negative discriminant." },
                { tex: "\\( (-4)^2 - 4(1)(k) < 0 \\)", note: "Substitute into \\(b^2 - 4ac\\)." },
                { tex: "\\( 16 - 4k < 0 \\implies 16 < 4k \\)", note: "Solve the linear inequality." },
                { tex: "\\( k > 4 \\)", note: "If \\(k\\) is greater than 4, the parabola stays entirely above the x-axis." }
            ]
        }
    ],
    trigonometry: [
        {
            title: "Simplifying with Compound Angles",
            question: "Simplify: \\( \\cos(x - 30^\\circ) - \\cos(x + 30^\\circ) \\)",
            steps: [
                { tex: "\\( (\\cos x \\cos 30 + \\sin x \\sin 30) - ( \\cos x \\cos 30 - \\sin x \\sin 30) \\)", note: "Expand both parts using compound angle identities." },
                { tex: "\\( \\cos x \\cos 30 + \\sin x \\sin 30 -  \\cos x \\cos 30 + \\sin x \\sin 30 \\)", note: "Watch the sign change when subtracting the second bracket!" },
                { tex: "\\( 2\\sin x \\sin 30 \\)", note: "The cosine terms cancel out." },
                { tex: "\\( 2\\sin x (0,5) = \\sin x \\)", note: "Substitute special angle values to reach the simplest form." }
            ]
        },
        {
            title: "Solving General Solution",
            question: "Find the general solution of \\( 2\\sin^2 \\theta = \\sin \\theta \\).",
            steps: [
                { tex: "\\( 2\\sin^2 \\theta - \\sin \\theta = 0 \\implies \\sin \\theta(2\\sin \\theta - 1) = 0 \\)", note: "DO NOT divide by \\(\\sin \\theta\\)! Always factorize to keep all solutions." },
                { tex: "\\( \\sin \\theta = 0 \\quad \\text{or} \\quad \\sin \\theta = 0,5 \\)", note: "Solve each factor separately." },
                { tex: "\\( \\theta = 180^\\circ \\cdot k \\quad (k \\in \\mathbb{Z}) \\)", note: "General solution for sine being zero." },
                { tex: "\\( \\theta = 30^\\circ + 360^\\circ k \\quad \\text{or} \\quad \\theta = 150^\\circ + 360^\\circ k \\)", note: "General solution for sine being 0,5." }
            ]
        },
        {
            title: "Trig Proof with Identities",
            question: "Prove: \\( \\frac{\\sin 2\\alpha}{1 + \\cos 2\\alpha} = \\tan \\alpha \\)",
            steps: [
                { tex: "\\( LHS = \\frac{2\\sin \\alpha \\cos \\alpha}{1 + (2\\cos^2 \\alpha - 1)} \\)", note: "Double angle sine has 1 form. For cosine, pick the one that cancels the '+1'." },
                { tex: "\\( \\frac{2\\sin \\alpha \\cos \\alpha}{2\\cos^2 \\alpha} \\)", note: "Simplify the denominator. The '1's cancel out." },
                { tex: "\\( \\frac{\\sin \\alpha}{\\cos \\alpha} = \\tan \\alpha \\)", note: "Divide by common factor \\(2\\cos \\alpha\\) to reach RHS." }
            ]
        }
    ],
    calculus: [
        {
            title: "Derivative from First Principles",
            question: "Find \\( f'(x) \\) if \\( f(x) = 2x^2 \\) using first principles.",
            steps: [
                { tex: "\\( f(x+h) = 2(x+h)^2 = 2x^2 + 4xh + 2h^2 \\)", note: "First, find and expand \\(f(x+h)\\)." },
                { tex: "\\( \\lim_{h \\to 0} \\frac{(2x^2 + 4xh + 2h^2) - (2x^2)}{h} \\)", note: "Substitute into the limit definition formula." },
                { tex: "\\( \\lim_{h \\to 0} \\frac{4xh + 2h^2}{h} = \\lim_{h \\to 0} (4x + 2h) \\)", note: "Factorize \\(h\\) out and cancel it with the denominator." },
                { tex: "\\( f'(x) = 4x \\)", note: "Let \\(h = 0\\). You can check this using power rules!" }
            ]
        },
        {
            title: "Finding Equations of Tangents",
            question: "Find equation of tangent to \\( f(x) = x^2 - 4 \\) at \\( x = 3 \\).",
            steps: [
                { tex: "\\( f(3) = (3)^2 - 4 = 5 \\)", note: "Find the y-coordinate of the point (3; 5)." },
                { tex: "\\( f'(x) = 2x \\implies f'(3) = 6 \\)", note: "Differentiate and substitute x=3 to find the gradient \\(m\\)." },
                { tex: "\\( y - 5 = 6(x - 3) \\)", note: "Use the point-gradient form of a straight line." },
                { tex: "\\( y = 6x - 13 \\)", note: "Expand and simplify to standard line form." }
            ]
        },
        {
            title: "Optimization (Cubic Maximum)",
            question: "A company's profit is \\( P(x) = -x^3 + 300x \\). Find the value of \\(x\\) for max profit.",
            steps: [
                { tex: "\\( P'(x) = -3x^2 + 300 \\)", note: "At a maximum, the rate of change is zero." },
                { tex: "\\( -3x^2 + 300 = 0 \\implies x^2 = 100 \\)", note: "Set the derivative to zero and solve for \\(x\\)." },
                { tex: "\\( x = 10 \\)", note: "We ignore \\(x = -10\\) as it's impossible in this context." },
                { tex: "\\( 10 \\text{ units} \\)", note: "Maximum profit occurs when 10 units are produced." }
            ]
        }
    ],
    patterns: [
        {
            title: "Arithmetic Sequence to Series",
            question: "The first 3 terms of an arithmetic sequence are \\( 2x-4 ; 5x-3 ; 7x+2 \\). Find \\(x\\) and the sum of the first 15 terms.",
            steps: [
                { tex: "\\( T_2 - T_1 = T_3 - T_2 \\)", note: "For an arithmetic sequence, the common difference \\(d\\) is constant." },
                { tex: "\\( (5x-3) - (2x-4) = (7x+2) - (5x-3) \\)", note: "Always use brackets when substituting expressions with multiple terms." },
                { tex: "\\( 3x + 1 = 2x + 5 \\implies x = 4 \\)", note: "Simplify both sides and solve the linear equation for \\(x\\)." },
                { tex: "\\( T_1 = 4 ; T_2 = 17 ; T_3 = 30 \\implies a = 4, d = 13 \\)", note: "Substitute \\(x\\) back into the original expressions to find \\(a\\) and \\(d\\)." },
                { tex: "\\( S_{15} = \\frac{15}{2}[2(4) + (15-1)(13)] = 1425 \\)", note: "Use the arithmetic sum formula \\(S_n = \\frac{n}{2}[2a + (n-1)d]\\)." }
            ]
        },
        {
            title: "Sum to Infinity of a Geometric Series",
            question: "Given the geometric series: \\( 18 + 6 + 2 + \\dots \\) Calculate the sum to infinity.",
            steps: [
                { tex: "\\( a = 18 \\quad \\text{and} \\quad r = \\frac{T_2}{T_1} = \\frac{6}{18} = \\frac{1}{3} \\)", note: "Identify the first term and the constant ratio." },
                { tex: "\\( -1 < r < 1 \\)", note: "Always check or state that the series converges because the ratio is between -1 and 1." },
                { tex: "\\( S_\\infty = \\frac{a}{1 - r} \\)", note: "State the sum to infinity formula." },
                { tex: "\\( S_\\infty = \\frac{18}{1 - \\frac{1}{3}} = \\frac{18}{\\frac{2}{3}} = 27 \\)", note: "Substitute and simplify. No decimals needed." }
            ]
        },
        {
            title: "Quadratic Number Pattern",
            question: "Given the quadratic pattern: \\( 3 ; 6 ; 11 ; 18 ; \\dots \\) Determine the general term \\( T_n \\).",
            steps: [
                { tex: "\\( \\text{1st diffs: } 3 ; 5 ; 7 \\)", note: "Find the first differences between consecutive terms." },
                { tex: "\\( \\text{2nd diffs: } 2 ; 2 \\)", note: "Find the constant second difference." },
                { tex: "\\( 2a = 2 \\implies a = 1 \\)", note: "The second difference is always equal to \\(2a\\)." },
                { tex: "\\( 3a + b = 3 \\implies 3(1) + b = 3 \\implies b = 0 \\)", note: "The first term of the first differences is \\(3a + b\\)." },
                { tex: "\\( a + b + c = 3 \\implies 1 + 0 + c = 3 \\implies c = 2 \\)", note: "The first term of the quadratic pattern is \\(a + b + c\\)." },
                { tex: "\\( T_n = n^2 + 2 \\)", note: "Substitute \\(a, b, c\\) into the general form \\(T_n = an^2 + bn + c\\)." }
            ]
        }
    ],
    finance: [
        {
            title: "Future Value Annuity (Saving)",
            question: "Thabo saves R500 at the end of every month for 5 years. The interest rate is 8% p.a. compounded monthly. Calculate his total savings.",
            steps: [
                { tex: "\\( x = 500 \\quad i = \\frac{0,08}{12} \\quad n = 5 \\times 12 = 60 \\)", note: "Identify the variables. Remember to divide the annual rate by 12 for monthly compounding." },
                { tex: "\\( F = \\frac{x[(1 + i)^n - 1]}{i} \\)", note: "State the Future Value annuity formula because payments are made to accumulate a future sum." },
                { tex: "\\( F = \\frac{500[(1 + \\frac{0,08}{12})^{60} - 1]}{\\frac{0,08}{12}} \\)", note: "Substitute accurately. Do not round off the interest rate in your calculator!" },
                { tex: "\\( F = \\text{R} 36 \\, 738,43 \\)", note: "Final answer should be rounded to two decimal places for currency." }
            ]
        },
        {
            title: "Present Value Annuity (Loan)",
            question: "Lerato takes a R200 000 loan to buy a car, paid back over 5 years. Interest is 10% p.a. compounded monthly. Find her monthly repayment.",
            steps: [
                { tex: "\\( P = 200000 \\quad i = \\frac{0,10}{12} \\quad n = 60 \\)", note: "A loan is a Present Value scenario because the large lump sum is given at the beginning." },
                { tex: "\\( P = \\frac{x[1 - (1 + i)^{-n}]}{i} \\)", note: "State the Present Value annuity formula." },
                { tex: "\\( 200000 = \\frac{x[1 - (1 + \\frac{0,10}{12})^{-60}]}{\\frac{0,10}{12}} \\)", note: "Substitute the known values. Now we solve for \\(x\\)." },
                { tex: "\\( x = \\frac{200000 \\times \\frac{0,10}{12}}{1 - (1 + \\frac{0,10}{12})^{-60}} \\)", note: "Rearrange to make \\(x\\) the subject." },
                { tex: "\\( x = \\text{R} 4 \\, 249,41 \\)", note: "Calculate carefully. Round to two decimal places." }
            ]
        },
        {
            title: "Effective Interest Rate",
            question: "Calculate the effective annual interest rate if the nominal rate is 11.5% p.a. compounded quarterly.",
            steps: [
                { tex: "\\( i^{(m)} = 0,115 \\quad m = 4 \\)", note: "Identify the nominal rate (as a decimal) and the compounding periods per year." },
                { tex: "\\( 1 + i_{eff} = \\left(1 + \\frac{i^{(m)}}{m}\\right)^m \\)", note: "State the standard effective vs nominal rate formula." },
                { tex: "\\( 1 + i_{eff} = \\left(1 + \\frac{0,115}{4}\\right)^4 \\)", note: "Substitute the values." },
                { tex: "\\( i_{eff} = (1,02875)^4 - 1 = 0,12006... \\)", note: "Subtract 1 to isolate the effective rate." },
                { tex: "\\( i_{eff} = 12,01\\% \\)", note: "Multiply by 100 to get the percentage and round to 2 decimal places." }
            ]
        }
    ],
    analytical_geometry: [
        {
            title: "Equation of a Circle with Center NOT at Origin",
            question: "Find the equation of a circle with center \\( (-3; 4) \\) passing through the point \\( (1; 1) \\).",
            steps: [
                { tex: "\\( (x - a)^2 + (y - b)^2 = r^2 \\)", note: "Start with the standard equation of a circle." },
                { tex: "\\( (x + 3)^2 + (y - 4)^2 = r^2 \\)", note: "Substitute the center \\((a; b) = (-3; 4)\\). Watch the double negative on the \\(x\\)!" },
                { tex: "\\( (1 + 3)^2 + (1 - 4)^2 = r^2 \\)", note: "Substitute the given point \\((1; 1)\\) for \\(x\\) and \\(y\\) to find \\(r^2\\)." },
                { tex: "\\( 4^2 + (-3)^2 = 16 + 9 = 25 \\implies r^2 = 25 \\)", note: "Calculate \\(r^2\\). The radius is 5, but we need \\(r^2\\) for the equation." },
                { tex: "\\( (x + 3)^2 + (y - 4)^2 = 25 \\)", note: "Write the final equation clearly." }
            ]
        },
        {
            title: "Equation of a Tangent to a Circle",
            question: "Determine the equation of the tangent line to the circle \\( x^2 + y^2 = 25 \\) at the point \\( P(-3; 4) \\).",
            steps: [
                { tex: "\\( m_{radius} = \\frac{y_2 - y_1}{x_2 - x_1} = \\frac{4 - 0}{-3 - 0} = -\\frac{4}{3} \\)", note: "First, find the gradient of the radius from the origin \\((0;0)\\) to point \\(P\\)." },
                { tex: "\\( m_{tangent} = \\frac{3}{4} \\)", note: "The tangent is perpendicular to the radius, so \\( m_1 \\times m_2 = -1 \\). Flip and change the sign!" },
                { tex: "\\( y - y_1 = m(x - x_1) \\)", note: "Use the point-gradient formula for a straight line." },
                { tex: "\\( y - 4 = \\frac{3}{4}(x + 3) \\implies y = \\frac{3}{4}x + \\frac{9}{4} + 4 \\)", note: "Substitute point \\(P(-3; 4)\\) and the tangent gradient." },
                { tex: "\\( y = \\frac{3}{4}x + \\frac{25}{4} \\)", note: "Simplify to standard form \\(y = mx + c\\)." }
            ]
        },
        {
            title: "Angle of Inclination",
            question: "Calculate the angle of inclination of the line \\( 2y - x = 6 \\).",
            steps: [
                { tex: "\\( 2y = x + 6 \\implies y = \\frac{1}{2}x + 3 \\)", note: "First, get the equation into standard form \\(y = mx + c\\) to find the gradient \\(m\\)." },
                { tex: "\\( m = \\frac{1}{2} \\)", note: "Identify the gradient." },
                { tex: "\\( \\tan \\theta = m \\implies \\tan \\theta = \\frac{1}{2} \\)", note: "Use the inclination formula \\(\\tan \\theta = m\\)." },
                { tex: "\\( \\theta = \\tan^{-1}(0,5) \\)", note: "Use shift-tan on your calculator." },
                { tex: "\\( \\theta = 26,57^\\circ \\)", note: "Round to 2 decimal places. If \\(m\\) was negative, add 180 to the resulting negative angle!" }
            ]
        }
    ],
    euclidean_geometry: [
        {
            title: "Proving a Cyclic Quadrilateral",
            question: "In a circle, chords \\(AB\\) and \\(CD\\) intersect at \\(E\\). If exterior angle at \\(B\\) equals the interior opposite angle at \\(D\\), prove \\(ABCD\\) is a cyclic quad.",
            steps: [
                { tex: "\\( \\text{Let ext } \\angle B = \\angle D_1 = x \\)", note: "Define the given information clearly with variables if it helps." },
                { tex: "\\( \\text{ext } \\angle \\text{ of cyclic quad} = \\text{int opp } \\angle \\)", note: "State the theorem you are using as your reason." },
                { tex: "\\( \\therefore ABCD \\text{ is a cyclic quad} \\)", note: "Conclude simply. Alternate ways: prove opposite angles add to 180, or angles in same segment are equal." }
            ]
        },
        {
            title: "Proportionality Theorem",
            question: "In \\(\\triangle ABC\\), \\(DE \\parallel BC\\). If \\(AD=2\\), \\(DB=3\\), and \\(AE=4\\), calculate \\(EC\\).",
            steps: [
                { tex: "\\( \\frac{AD}{DB} = \\frac{AE}{EC} \\)", note: "State the proportionality ratio." },
                { tex: "\\( \\text{Reason: line } \\parallel \\text{ to one side of } \\triangle \\)", note: "Always state your Euclidean geometry reason!" },
                { tex: "\\( \\frac{2}{3} = \\frac{4}{EC} \\)", note: "Substitute the known lengths." },
                { tex: "\\( 2EC = 12 \\implies EC = 6 \\)", note: "Cross-multiply and solve." }
            ]
        },
        {
            title: "Proving Triangles Similar",
            question: "Prove that \\(\\triangle ADE \\||| \\triangle ABC\\) if \\(\\angle A\\) is common and \\(\\angle ADE = \\angle C\\).",
            steps: [
                { tex: "\\( \\text{In } \\triangle ADE \\text{ and } \\triangle ABC: \\)", note: "Format your proof by clearly stating which two triangles you are working in." },
                { tex: "\\( 1. \\quad \\angle A = \\angle A \\quad \\text{(Common)} \\)", note: "First pair of equal angles. State the reason." },
                { tex: "\\( 2. \\quad \\angle ADE = \\angle C \\quad \\text{(Given)} \\)", note: "Second pair of equal angles. State the reason." },
                { tex: "\\( 3. \\quad \\angle AED = \\angle B \\quad \\text{(Sum of } \\angle\\text{s in } \\triangle) \\)", note: "If two angles are equal, the third MUST be equal." },
                { tex: "\\( \\therefore \\triangle ADE \\||| \\triangle ABC \\quad (\\angle, \\angle, \\angle) \\)", note: "Final conclusion and the case for similarity." }
            ]
        }
    ],
    probability: [
        {
            title: "Independent Events",
            question: "Events A and B are independent. \\(P(A) = 0,4\\) and \\(P(B) = 0,5\\). Calculate \\(P(A \\text{ or } B)\\).",
            steps: [
                { tex: "\\( P(A \\text{ and } B) = P(A) \\times P(B) \\)", note: "Crucial rule: For independent events, the probability of BOTH happening is their product." },
                { tex: "\\( P(A \\text{ and } B) = 0,4 \\times 0,5 = 0,2 \\)", note: "Calculate the intersection first." },
                { tex: "\\( P(A \\text{ or } B) = P(A) + P(B) - P(A \\text{ and } B) \\)", note: "State the general addition rule." },
                { tex: "\\( P(A \\text{ or } B) = 0,4 + 0,5 - 0,2 = 0,7 \\)", note: "Substitute and solve." }
            ]
        },
        {
            title: "Fundamental Counting Principle (Arrangements)",
            question: "How many different 5-letter arrangements can be made from the word 'APPLE'?",
            steps: [
                { tex: "\\( n = 5 \\)", note: "Total number of letters." },
                { tex: "\\( \\text{Repeats: 'P' appears } 2 \\text{ times.} \\)", note: "Identify any identical items because shifting them doesn't create a 'different' word." },
                { tex: "\\( \\text{Total} = \\frac{5!}{2!} \\)", note: "Formula is \\( \\frac{n!}{r_1! \\times r_2! \\dots} \\)" },
                { tex: "\\( \\text{Total} = \\frac{120}{2} = 60 \\)", note: "Calculate the final number. 60 unique arrangements." }
            ]
        },
        {
            title: "Mutually Exclusive Events",
            question: "If \\(P(A) = 0,3\\), \\(P(B) = 0,4\\) and \\(P(A \\text{ or } B) = 0,7\\), are A and B mutually exclusive?",
            steps: [
                { tex: "\\( P(A \\text{ or } B) = P(A) + P(B) - P(A \\text{ and } B) \\)", note: "Always start with the addition rule equation." },
                { tex: "\\( 0,7 = 0,3 + 0,4 - P(A \\text{ and } B) \\)", note: "Substitute the given probabilities." },
                { tex: "\\( 0,7 = 0,7 - P(A \\text{ and } B) \\implies P(A \\text{ and } B) = 0 \\)", note: "Solve for the intersection." },
                { tex: "\\( \\text{Yes, they are mutually exclusive.} \\)", note: "Since the intersection is 0, they cannot happen at the same time." }
            ]
        }
    ],
    statistics: [
        {
            title: "Equation of the Least Squares Regression Line",
            question: "A data set gives \\(\\bar{x} = 10\\), \\(\\bar{y} = 24\\), and \\(b = 2.1\\). Find the equation of the regression line \\( \\hat{y} = a + bx \\).",
            steps: [
                { tex: "\\( \\hat{y} = a + bx \\)", note: "The regression line ALWAYS passes through the mean point \\( (\\bar{x}; \\bar{y}) \\)." },
                { tex: "\\( 24 = a + 2,1(10) \\)", note: "Substitute \\(\\bar{y}\\), \\(\\bar{x}\\), and \\(b\\) to solve for the y-intercept \\(a\\)." },
                { tex: "\\( 24 = a + 21 \\implies a = 3 \\)", note: "Calculate \\(a\\)." },
                { tex: "\\( \\hat{y} = 3 + 2,1x \\)", note: "Write the final equation." }
            ]
        },
        {
            title: "Standard Deviation and the Mean",
            question: "A data set has a mean of 45 and a standard deviation of 4. Between what two values does approx 68% of the data lie?",
            steps: [
                { tex: "\\( \\bar{x} = 45 \\quad \\text{and} \\quad \\sigma = 4 \\)", note: "Identify the mean and standard dev." },
                { tex: "\\( \\text{Interval for } 68\\% \\text{ is } [\\bar{x} - \\sigma ; \\bar{x} + \\sigma] \\)", note: "Recall the normal distribution rule: 68% of data lies within 1 standard deviation of the mean." },
                { tex: "\\( [45 - 4 ; 45 + 4] \\)", note: "Substitute the values." },
                { tex: "\\( [41 ; 49] \\)", note: "Calculate the lower and upper bounds. 68% of the data is between 41 and 49." }
            ]
        },
        {
            title: "Using an Ogive (Cumulative Frequency Graph)",
            question: "An Ogive represents the marks of 80 students. How would you estimate the median mark?",
            steps: [
                { tex: "\\( \\text{Total frequency } (n) = 80 \\)", note: "Identify the maximum value on the y-axis (Cumulative Frequency)." },
                { tex: "\\( \\text{Median Position} = \\frac{n}{2} = \\frac{80}{2} = 40 \\)", note: "The median is the 50th percentile, so half the total frequency." },
                { tex: "\\( \\text{Find 40 on the y-axis (Cumulative Frequency)} \\)", note: "Locate this value on the vertical axis." },
                { tex: "\\( \\text{Read across to the curve, then down to the x-axis} \\)", note: "The corresponding x-value (Mark) is your estimated median." }
            ]
        }
    ]
};
