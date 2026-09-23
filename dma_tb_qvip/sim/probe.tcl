database -open waves -shm -into waves.shm -default
probe -create dma_tb_hdl_top -depth all -all
run;
exit
