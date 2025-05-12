# Miniproject Feedback and Assessment

## Report

**"Guidelines" below refers to the MQB report [MQB Miniproject report guidelines](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html#the-report) [here](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html) (which were provided to the students in advance).**


**Title:** “Gompertz Model Outperforms Logistic and Cubic Models in Predicting Bacterial Growth”

- **Introduction (15%)**  
  - **Score:** 11/15  
  - Stresses importance of capturing lag phase. Could specify a sharper question or gap.

- **Methods (15%)**  
  - **Score:** 11/15  
  - Mentions random starts with NLS but not in depth. The [MQB Miniproject report guidelines](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html#the-report) call for details on param bounds or how many iterations.

- **Results (20%)**  
  - **Score:** 13/20  
  - States Gompertz is best by AIC/BIC. Minimal numeric breakdown. A summary table of wins would add clarity.

- **Tables/Figures (10%)**  
  - **Score:** 5/10  
  - A “summary table” is hinted at but not well integrated. The [MQB Miniproject report guidelines](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html#the-report) emphasize referencing each figure/table thoroughly.

- **Discussion (20%)**  
  - **Score:** 14/20  
  - Points out cubic's limited biological interpretability, logistic's issue with lag phases, Gompertz's advantage. Could further discuss data coverage or next steps.

- **Style/Structure (20%)**  
  - **Score:** 16/20  
  - Organized sections, reasonably clear writing. More references to data or figures is suggested.

**Summary:** Captures the main differences among models but lacks numeric tables or deep integration of results. More thorough methods detail would improve replicability.

**Report Score:** 67  

---

## Computing

### Project Structure & Workflow

**Strengths**

* **Simplicity:** A minimal setup—one shell script and one R script—makes the pipeline easy to follow and execute.
* **Integration:** The Bash driver orchestrates data processing, model fitting, and LaTeX report generation with clear status messages.
* **Clarity:** File naming is intuitive, and responsibilities are well separated between the driver and the analysis code.

**Recommendations**

1. **Enhance the shell script (`miniproject.sh`):**

   * Use a portable shebang: `#!/usr/bin/env bash`.
   * Add strict mode:

     ```bash
     set -euo pipefail
     cd "$(dirname "$0")"  # ensure consistent working directory
     ```
   * Capture both stdout and stderr in a log:

     ```bash
     bash miniproject.sh |& tee ../results/pipeline_$(date +'%Y%m%d_%H%M%S').log
     ```
   * Allow configurable paths via flags (e.g. `--data-dir`, `--results-dir`).

2. **Lock environments:**

   * **R:** Initialize `renv` within `code/`, commit the `renv.lock` file, and run `renv::restore()` before executing the analysis script.
   * **System tools:** Document required external tools (`pdflatex`, `bibtex`) and their versions in the README.

---

### README File

**Strengths**

* Outlines the project objective, prerequisites, and basic usage commands.
* Enumerates dependencies for R and LaTeX.

**Recommendations**

1. **Provide installation and execution steps**:

   ```bash
   git clone <repo_url> && cd MiniProject/code
   Rscript -e "renv::restore()"    # Restore R packages
   bash miniproject.sh              # Run analysis and compile report
   ```
2. **Visualize directory structure** with a tree diagram, clarifying where data, code, and results reside.
3. **Describe each script’s role**, including its inputs and outputs under a **Code** section.
4. **Include a license** (e.g., MIT) and **cite the data source** in a **Data** section.
5. **Add a troubleshooting guide**, pointing users to the log file for common errors (e.g., missing packages, LaTeX failures).

---

## `miniproject.sh`

**Recommendations**

* Ensure the script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
* Call `cd "$(dirname "$0")"` to run from the `code/` folder.
* Limit temporary files to a subdirectory (e.g., `temp/`) to avoid accidental deletions.
* Replace `evince` with a variable (e.g., `$PDF_VIEWER`) or omit in headless runs.

---

## Analysis Script (`miniproject_code.R`)

### Code Organization & Style

**Strengths**

* Loads all required libraries upfront.
* Uses the pipe (`%>%`) for clear data transformations.
* Splits the dataset by `ID` and applies model fitting in a loop.

**Recommendations**

    Extract repeated logic into named functions at the top of the script, such as `clean_data()`, `split_data()`, `fit_model()`, and `plot_results()`.

1. Wrap the main workflow in a `main <- function() { ... }` and call it via:

   ```r
   if (interactive()) main()
   ```

This will allow the script to be sourced without immediate execution and improves testability.

1. Use `here::here()` to construct file paths and `fs::dir_create()` to ensure output directories exist.
2. Use `message()` or the `cli` package to provide informative progress updates.
3. Call `set.seed(1234)` once before all random operations to guarantee reproducibility.

#### NLLS Fitting Approach

**Strengths**

* Implements multi‐start sampling for logistic and Gompertz models to mitigate local minima.
* Filters fits by R² > 0.7 to retain robust results.
* Defines custom growth functions and leverages `nlsLM()` from `minpack.lm`.

**Recommendations**

1. **`nls.multstart`:** Simplifies multi-start, bounds handling, and confidence interval estimation; e.g.:

   ```r
   nls_multstart(
     PopBio ~ logistic_growth(Time, K, r, N0),
     data = df,
     iter = 10,
     start_lower = c(K = min(df$PopBio), r = 0, N0 = min(df$PopBio)),
     start_upper = c(K = max(df$PopBio) * 2, r = 1, N0 = max(df$PopBio)),
     supp_errors = 'Y'
   )
   ```
2. Enforce biologically plausible bounds (`r ≥ 0`, `K ≥ N0`) and flag boundary hits as warnings.
3. Use `future.apply::future_lapply()` for large datasets to distribute fits across cores.
4. Record errors and warnings in a data frame (`ID`, `model`, `error_message`) for later inspection.
5. Implement leave-one-timepoint-out or k-fold CV to evaluate predictive performance.

#### Plotting & Model Comparison

**Strengths**

* Offers visual overlays of observed vs. fitted curves.
* Produces a summary CSV with R², AIC, and BIC for each ID.

**Recommendations**

1. Build plots using layered geoms and long-format data rather than base plotting.
2. Iterate over IDs with `purrr::walk()`, saving each plot via `ggsave()`.
3. Compute weights with `AICcmodavg::Weights()` and visualize their distribution (e.g., boxplots).
4. Define `theme_minimal()` and a color palette once, then apply throughout for visual consistency.

---

## Summary

Good pipeline. By introducing environment locking (e.g., `renv`), modularizing code into reusable functions, leveraging `nls.multstart` for robust NLLS, and enhancing logging and parallel execution, you can further improve reproducibility, maintainability, and analytical depth. 

### Score: 68

---

## Overall Score: (67+68)/2 = 67.5