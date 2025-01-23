
# Final Assessment for Zhilu

- The overall directory structure was fine.#
- You had an .gitignore, good! You could have done with more exclusions specific to certain weeks (remember that you can include/exclude subdirectories/files/patterns). You may [find this useful](https://www.gitignore.io).
- The main `README.md` provided an overview of the coursework and its structure, which was helpful. However, weekly directories could benefit from more detailed instructions on running specific scripts.
- Weekly subdirectories (e.g., `code`, `data`, `results`) were appropriately organized. Empty result directories were a good practice for maintaining a clean structure.

## Week 1
- Scripts like `csvtospace.sh`, `ConcatenateTwoFiles.sh`, and `tabtocsv.sh` demonstrated robust error handling, such as checking file existence and validating input arguments - good.
- `CountLines.sh` lacked input validation, leading to ambiguous redirect errors when no file was specified. This should have been addressed by verifying `$1` before processing.
- Minor formatting issues detected, such as inconsistent indentation.

## Week 2
- Unnecessarily leaving `ipdb` in scripts resulted in syntax errors!
- Missing or minimal docstrings in scripts like `dictionary.py` and `MyExampleScript.py` reduced readability and maintainability.
- You could have formatted the output of certain scripts to be  more neat / organised / informative (compare with my solutions) -- for example `lc1.py` is perfectly functional, but the formatting of the output could have been improved.

## Week 3
- `TreeHeight.R` and `Florida.R` were well-structured and included appropriate comments, demonstrating improved mastery of complex data analysis, and visualization.
- Errors in `MyScript.R` (??) due to file paths (`basic_io.R` was missing) .

## Week 4
- The final week's scripts showed significant improvement in error handling and organization. However, the lack of README updates for new additions in the `week4` directory was a missed opportunity.
- The `Florida.R` script implemented statistical testing effectively. The permutation testing logic was correct and well-documented.
- The LaTeX report (`Florida_latex_code.tex`) included clear sections for methods, results, and conclusions. Some minor typographical errors. 
- Your Groupwork practicals were all in order, and your group did well in collaborating on it based on the commit/merge/pull history. Check the groupwork feedback pushed to your group repo for more details.  
  - The Autocorrelation practical was fine -- the code  was reasonably efficient , whilst providing a correct answer to the question. The  provided statistical and biological/ecological interpretations in the report could have been stronger; has a somewhat weak conclusion at the end.
 

## Git Practices
- Commits were frequent but lacked meaningful messages, such as "update" or "fix". Descriptive messages would have provided better context for changes.
- Contributions appeared consistent across weeks, but some binary files were committed, unnecessarily increasing repository size.
- The repository size of 2.89 MiB was reasonable. The `.gitignore` effectively excluded temporary and unnecessary files.

## Recommendations
1. Add detailed usage instructions in weekly README files.
2. Ensure scripts include comprehensive error handling and test coverage.
3. Improve commit message quality to reflect changes more accurately.
4. Avoid committing binary files to keep the repository size manageable.

## Overall Assessment

You did a OK job overall! 

Some of your scripts retained fatal errors which could nave been easily fixed - work on being more vigilant and persistent in chasing down errors the future.

Commenting could be improved -- you are currently erring on the side of overly verbose comments at times (including in your readmes), which is nonetheless better than not commenting at all, or too little! This will improve with experience, as you will begin to get a feel of what is ``common-knowledge'' among programmers, and what stylistic idioms are your own and require explanation. In general though, comments should be written to help explain a coding or syntactical decision to a user (or to your future self re-reading the code!) rather than to describe the meaning of a symbol, argument or function (that should be in the function docstring in Python for example).

It was a tough set of weeks, but I believe your hard work in them has given you a great start towards further training, a quantitative masters dissertation, and ultimately a career in quantitative biology!

### (Provisional) Mark
 *67*