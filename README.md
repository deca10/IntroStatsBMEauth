# R for Sport & Exercise Science: interactive course

**👉 Open the course: https://deca10.github.io/IntroStatsBMEauth/**

A self-paced Quarto website. Students read short explanations, run R **in the browser** (webR via the
[quarto-live](https://r-wasm.github.io/quarto-live/) extension), solve auto-graded exercises with hints and
solutions, and take quizzes. Progress (completed lessons, quiz results) is stored in each student's browser.

## Structure

| File | Content |
|---|---|
| `index.qmd` | Home page, progress dashboard, course map |
| `how-to-use.qmd` | How the platform works, dataset description, RStudio setup |
| `m1-01-basics.qmd` … `m1-06-checkpoint.qmd` | Module 1 · Introduction to R |
| `m2-01-what-is-statistics.qmd` … `m2-05-checkpoint.qmd` | Module 2 · Introduction to statistics |
| `m3-01-summaries.qmd` … `m3-06-checkpoint.qmd` | Module 3 · Data visualisation in depth |
| `m4-01-confidence-intervals.qmd` … `m4-11-checkpoint.qmd` | Module 4 · Inferential statistics |
| `_common.qmd` | Included on every live page: loads quarto-live + hidden grading helpers |
| `assets/course.html` | Quiz engine, "mark complete", sidebar ✓ marks, sequence reminder, progress dashboard |
| `assets/course.css`, `assets/theme.scss` | Styling |
| `data/balance.csv`, `data/bds_trials.csv` | Course data (built by `scripts/prepare_data.R` from `BDSinfo.xlsx`) |
| `data/cmj.csv` | 3 CMJ force recordings, 500 Hz, anonymised as "Athlete K" (built by `scripts/prepare_cmj.R`) |
| `data/slope_walking.csv` | Heart rate and walking speed of 10 participants walking downhill, level and uphill (10°); participants coded P01–P10 |
| `data/jump_squad.csv`, `data/cmj_trials.csv` | 84-athlete CMJ variables and 56 × 3 repeated CMJs, names replaced by codes (built by `scripts/prepare_squad.R` from the GRF classification project) |
| `scripts/test_exercises.R` | Runs every demo block, and every solution through its grader, in local R |
| `docs/` | Rendered website (publish this folder) |

## Build and preview

Quarto ships with RStudio. From this folder:

```bash
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto preview
```

(or install Quarto from https://quarto.org and use `quarto preview` / `quarto render`). In RStudio you can also
open any `.qmd` and click **Render**.

Before publishing, check that all solutions pass their graders:

```bash
Rscript scripts/test_exercises.R
```

## Publishing

`quarto render` writes the static site to `docs/`. It needs no R server, so any static host works:

- **GitHub Pages**: push the repo and set Pages to serve from the `docs/` folder on the main branch.
- **Netlify / university web space**: upload the contents of `docs/`.

Note: open the site through a web server (not by double-clicking the HTML file), otherwise webR can't load.

## Writing content

**Exercise pattern** (copy-paste and change the label `ex_label` everywhere):

````markdown
::: {.task}
What the student must do.
:::

```{webr}
#| exercise: ex_label
#| caption: "Exercise · Title"
x <- ______
```

::: {.hint exercise="ex_label"}
A nudge.
:::

::: {.solution exercise="ex_label"}
```{webr}
#| exercise: ex_label
#| solution: true
x <- 42
```
:::

```{webr}
#| exercise: ex_label
#| check: true
.check_vars("x", .envir_result, .checker_args$envir_solution, ok = "Correct!")
```
````

Grading helpers (defined in `_common.qmd`):

- `.check_result(.result, .checker_args$solution, ok, no)`: compares the value of the last line
- `.check_vars(c("a", "b"), .envir_result, .checker_args$envir_solution, ok)`: compares created variables
- `.check_code(.user_code, c("mean(", "subset("), ok)`: requires pieces of code
- `.check_plot(.result, geoms = c("GeomPoint"), aes = c("colour"), ok)`: checks a ggplot's layers and aesthetics
- `.ok(msg)` / `.no(msg)`: build custom feedback

**Quiz pattern** (the ticked box is the correct answer):

```markdown
::: {.quiz id="unique-id"}
Question?

- [ ] wrong
- [x] right
- [ ] wrong

::: {.explanation}
Shown after the correct answer is found.
:::
:::
```

End every lesson with `::: {.lesson-complete}` / `:::`. When you add a lesson, add it to the sidebar in
`_quarto.yml` **and** to the `LESSONS` list at the top of `assets/course.html` (this drives the order,
progress dashboard and reminders).

Pages that need data or packages declare them in the YAML header:

```yaml
webr:
  packages: ['ggplot2']
  resources:
    - data/balance.csv
```

## Data source

Santos, D. A., & Duarte, M. (2016). A public data set of human balance evaluations. *PeerJ*, 4, e2648.
https://doi.org/10.7717/peerj.2648
