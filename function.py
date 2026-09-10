
def update_checker_status(
    file_path_A,
    file_path_B,
    sheet_name_A,
    sheet_name_B,
    vcd_id_col_idx_A,
    vprd_col_idx_A,
    checker_col_idx_A,
    log_col_idx_A,
    vprd_id_col_idx_B,
    checker_col_idx_B,
    target_col_idx_A,
    min_row_A=7,
    min_row_B=2,
    header="Checker Status"):
    
    start_time = time.time()


    # write logic here
    wb_vcd = load_workbook(file_path_A)
    wb_vprd = load_workbook(file_path_A)
    ws_vcd = wb_vcd[sheet_name_A]
    ws_vprd = wb_vprd[sheet_name_B]

    vprd_checker_mapping ={}
    for row in ws_vprd.iter_rows(min_row=min_rowB, max_col=50, values_only=True):
        vprd_id = row[vprd_id_col_idx_B]
        vprd_checker = row[checker_col_idx_B]
        vprd_checker_mapping[vprd_id] = vprd_checker



    # for each row in ws_vcd, store vcd_id_col_idx_A,vprd_col_idx_A,checker_col_idx_A,log_col_idx_A in a variable
    # store vprd as 1st word in vprd_id_col_idx_A
    for row in ws_vcd.iter_rows(min_row=min_rowA, max_col=50, values_only=True):
        vcd_id = row[vcd_id_col_idx_A]
        vprd = row[vprd_col_idx_A]
        associated_vprd_id = vprd.split()[0] if vprd else ""
        vcd_checker = row[checker_col_idx_A]
        log = row[log_col_idx_A]
        associated_vprd_checker = vprd_checker_mapping[associated_vprd_id]
        user_prompt = f"Trace Checkers: {vcd_checker} \nVPRD Checkers: {associated_vprd_checker} \nLog Checkers: {log}"
        print(user_prompt)
        break





    wb_vcd.save(file_path_A)
    _time(start_time)
