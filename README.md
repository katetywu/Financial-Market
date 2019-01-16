# Relationship between financing and productivity
### Summary
To examine the relationship between financing and productivity in India, this analysis uses Prowess database from [Center of Monitoring Indian Economy](https://www.cmie.com/), which contains over 48,000 manufacturing companies and has a 25-year time series for the older companies. Econometrics and quantitative economics concepts are used to define the model. STATA was used to analyze the whole study and STATA kernel in Jupyter Notebook will show the processes and codes here. The goal is to test whether the causality existed in this relationship.

### Process
![Process](https://github.com/katetywu/Financial-Market/blob/master/Image/FM_Process.jpg)

### Models
#### (1) Baseline
![Equ.1](https://github.com/katetywu/Financial-Market/blob/master/Image/Equation1.jpg)<br>
Where an individual firm is indexed i in the industry j at state k for each year t. Output (Y) defines a firm’s productivity calculated by the total sales, the gross fixed assets, and the net fixed assets. Borrowings from banks (Loans) are categorized in several groups including the aggregate loans, short-term loans, long-term loans; short-term loans from private and public sector banks, and long-term loans from private and public sector banks.<br><br>
#### (2) Robust Specification
![Equ.2](https://github.com/katetywu/Financial-Market/blob/master/Image/Equation2.jpg)<br>
The causal effect of loans on productivity is not obvious. Short-term loans, which are no longer than 12 months, can cause temporary cash flow that enables firms to have abrupt outcome on productivities. Long-term loans, which last at least 12 months, allow firms to have graudally growth on productivities. However, either way is only able to confirm the correlation. With the one-year lag, we may be can detect the causality between loans and productivies.

### Findings
(1) Various types of loans (short- and long-terms) are correlated with productivities calculated by total sales, gross fixed assets and net fixed assets. This finding is identical to most papers.<br>
(2) Short-term loans have more influences on productivities than long-term loans.<br>
(3) Loans lent by private sector banks are important to firms' productivities.<br>
(4) Computer software firms highly rely on long-term loans, while non-computer-software firms are dependent on short-term loans; but they all borrow loans from private sector banks.<br>
(5) There is not an obvious causality between financing and productivity, but this study is still working on it.
