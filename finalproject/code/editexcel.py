import pandas as pd

# 读取原始文件，跳过前面注释行（从第11行开始是表头）
df = pd.read_csv("data/customed_data_new.csv")

# 删除所有包含 'References' 的行，以及该行之后的连续引用内容行
# 我们先标记所有包含 'References' 的行索引
reference_indices = df[df.apply(lambda row: row.astype(str).str.contains('References').any(), axis=1)].index

# 创建要删除的索引集合
rows_to_drop = set()
for idx in reference_indices:
    rows_to_drop.add(idx)
    # 循环向下添加连续的引用行（直到下一行为空或开始为新 strain 的数据）
    i = idx + 1
    while i < len(df) and df.iloc[i].isnull().sum() < len(df.columns):  # 判断是否是空行
        rows_to_drop.add(i)
        i += 1

# 删除这些行
df_cleaned = df.drop(index=rows_to_drop).reset_index(drop=True)

columns_to_drop = [
    "strains.Culture collection no.",
    "strains.Strain Designation",
    "strains_tax_PNU.Species",
    "strains_tax_PNU.ID_reference",
    "culture_temp.ID_reference",
    "culture_pH.ID_reference"
]

# 只删除那些实际存在的列（防止列名错误时报错）
columns_to_drop = [col for col in columns_to_drop if col in df_cleaned.columns]

# 删除列
df_cleaned = df_cleaned.drop(columns=columns_to_drop)

# 保存结果
df_cleaned.to_csv("data/customed_data_new_1.csv", index=False)



