# 50 MHz clock input
set_location_assignment PIN_D25 -to Clk

# Reset  : KEY[0]
set_location_assignment PIN_AA14 -to RST

# Assignments for speed factor to help visualing and debbuging

# SW0
set_location_assignment PIN_W15 -to SPEED_FAC[0] 
# SW1
set_location_assignment PIN_AA15 -to SPEED_FAC[1]

# Assignments for Seven-Segment Displays (HEX0 - HEX5) on DE1-SoC Board

# HEX0 -> ssd_SecU (abcdefg)
set_location_assignment PIN_AE26 -to ssd_SecU[0]  
set_location_assignment PIN_AE27 -to ssd_SecU[1]  
set_location_assignment PIN_AE28 -to ssd_SecU[2]  
set_location_assignment PIN_AG27 -to ssd_SecU[3]  
set_location_assignment PIN_AF28 -to ssd_SecU[4]  
set_location_assignment PIN_AG28 -to ssd_SecU[5]  
set_location_assignment PIN_AH28 -to ssd_SecU[6]  

# HEX1 -> ssd_SecT (abcdefg)
set_location_assignment PIN_AJ29 -to ssd_SecT[0]  
set_location_assignment PIN_AH29 -to ssd_SecT[1]  
set_location_assignment PIN_AH30 -to ssd_SecT[2]  
set_location_assignment PIN_AG30 -to ssd_SecT[3]  
set_location_assignment PIN_AF29 -to ssd_SecT[4]  
set_location_assignment PIN_AF30 -to ssd_SecT[5]  
set_location_assignment PIN_AD27 -to ssd_SecT[6]  

# HEX2 -> ssd_MinU (abcdefg)
set_location_assignment PIN_AB23 -to ssd_MinU[0]  
set_location_assignment PIN_AE29 -to ssd_MinU[1]  
set_location_assignment PIN_AD29 -to ssd_MinU[2]  
set_location_assignment PIN_AC28 -to ssd_MinU[3]  
set_location_assignment PIN_AD30 -to ssd_MinU[4]  
set_location_assignment PIN_AC29 -to ssd_MinU[5]  
set_location_assignment PIN_AC30 -to ssd_MinU[6]  

# HEX3 -> ssd_MinT (abcdefg)
set_location_assignment PIN_AD26 -to ssd_MinT[0]  
set_location_assignment PIN_AC27 -to ssd_MinT[1]  
set_location_assignment PIN_AD25 -to ssd_MinT[2]  
set_location_assignment PIN_AC25 -to ssd_MinT[3]  
set_location_assignment PIN_AB28 -to ssd_MinT[4]  
set_location_assignment PIN_AB25 -to ssd_MinT[5]  
set_location_assignment PIN_AB22 -to ssd_MinT[6]  

# HEX4 -> ssd_HourU (abcdefg)
set_location_assignment PIN_AA24 -to ssd_HourU[0] 
set_location_assignment PIN_Y23  -to ssd_HourU[1]  
set_location_assignment PIN_Y24  -to ssd_HourU[2]  
set_location_assignment PIN_W22  -to ssd_HourU[3]  
set_location_assignment PIN_W24  -to ssd_HourU[4]  
set_location_assignment PIN_V23  -to ssd_HourU[5] 
set_location_assignment PIN_W25  -to ssd_HourU[6] 

# HEX5 -> ssd_HourT (abcdefg)
set_location_assignment PIN_V25  -to ssd_HourT[0]  
set_location_assignment PIN_AA28 -to ssd_HourT[1]  
set_location_assignment PIN_Y27  -to ssd_HourT[2]  
set_location_assignment PIN_AB27 -to ssd_HourT[3] 
set_location_assignment PIN_AB26 -to ssd_HourT[4] 
set_location_assignment PIN_AA26 -to ssd_HourT[5] 
set_location_assignment PIN_AA25 -to ssd_HourT[6] 
