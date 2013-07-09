section .text
;--------------------------------------------------------------------------------------------------
; r10, r11 - first item
; r12, r13 - second item
; r8, r9 - return values
minus:
    mov r8, r10
    sub r8, r12
    mov r9, r11
    ret
;--------------------------------------------------------------------------------------------------
; r10, r11 - first item
; r12, r13 - second item
; r8, r9 - return values
sum:
    inc_efirst_loop:
        cmp r11, r13
        jge final_inc_efirst_loop
        inc r11
        shr r10, 1
        jmp inc_efirst_loop
    final_inc_efirst_loop:
    inc_esecond_loop:
        cmp r13, r11
        jge final_inc_esecond_loop
        inc r13
        shr r12, 1
        jmp inc_esecond_loop
    final_inc_esecond_loop:
    mov r8, r10
    mov r9, r11
    add r8, r12
    ret
;--------------------------------------------------------------------------------------------------
; r10, r11 - first item
; r12, r13 - second item
; r8, r9 - return values
multiply:
    push r14
    push r15
    push rax
    push rbx
    mov r9, r11
    add r9, r13
    add r9, 64
    push r9

    mov rsi, 0xFFFFFFFF
    mov rax, r10
    shr rax, 32
    mov rbx, r10
    and rbx, rsi
    mov rcx, r12
    shr rcx, 32
    mov rdx, r12
    and rdx, rsi

    mov r10, rax
    mov r11, rbx
    mov r12, rcx
    mov r13, rdx

; r10 - a, r11 - b, r12 - c, r13 - d, r14 - ac, r15 - ad
    mov rax, r10
    xor rdx, rdx
    mul r12
    mov r14, rax
    xor rdx, rdx
    mov rax, r10
    mul r13
    mov r15, rax

; r10 - bc
    xor rdx, rdx
    mov rax, r11
    mul r12
    mov r10, rax

    xor rdx, rdx
    mov rax, r11
    mul r13

    mov r13, rax
    mov r11, r10
    mov r10, r14
    mov r12, r15

;  r10 - ac, r11 - bc, r12 - ad, r13 - bd
    
    mov r15, 1
    shl r15, 31
    mov r14, r15
    mov r15, r13
    shr r15, 32
    add r14, r15
    mov r15, r12
    and r15, rsi
    add r14, r15
    mov r15, r11
    and r15, rsi
    add r14, r15

    mov r8, r10
    mov r15, r12
    shr r15, 32
    add r8, r15
    mov r15, r11
    shr r15, 32
    add r8, r15
    mov r15, r14
    shr r15, 32
    add r8, r15

    pop r9
    pop rbx
    pop rax
    pop r15
    pop r14
    ret
;--------------------------------------------------------------------------------------------------
; rdi - incoming double
; r8, r9 - return values
construct_it:
    push r10
    mov r8, rdi
    mov r10, r8
    mov r9, 0xFFFFFFFFFFFFF
    and r8, r9
    mov r9, 1
    shl r9, 52
    or r8, r9
    shl r8, 8
    mov r9, r10
    shr r9, 52
    sub r9, 1083
    pop r10
    ret

;--------------------------------------------------------------------------------------------------
; r8, r9 - M_plus_version
; r10, r11 - delta
; rsi - buffer
; r12 - len
; r13 - K
;-----------
; registers mapping(from code; for more convenient navigating)
; rbx = p1, rcx = p2
; rax = iterator; rdx = divider; rdi = current_val
; new structure in r14, r15
get_chars:
	push r15
    ; n = r15
    mov r15, r9
    sub r15, r11
    add r11, r15
    mov rdx, r15
    for_divide_loop:
		cmp r15, 0
		jle final_for_divide_loop
        shr r10, 1
        sub rdx, 1
        jmp for_divide_loop
	final_for_divide_loop:
    ; new structure in r14, r15
    mov rcx, r9
    neg rcx
    mov r14, 1
    shl r14, cl
    mov r15, r9
    ; rbx = p1, rcx = p2
    mov rbx, r8
    mov rcx, r15
    neg rcx
    shr rbx, cl
    
	mov rcx, r8
    mov rax, r14
    sub rax, 1
    and rcx, rax

    mov r12, 0
	; rax = iterator; rdx = divider; rdi = current_val
    mov rax, 10
    mov rdx, 1000000000

    loop_it_not_zero:
        cmp rax, 0
        je final_loop_it_not_zero
        push rax
		push rcx
        push rdx
		mov rcx, rdx
		xor rdx, rdx
        mov rax, rbx
        div rcx
        mov rbx, rdx ; remainer
        mov rdi, rax

        pop rdx
		pop rcx
        pop rax


        cmp rdi, 0
        jnz need_to_add_to_buffer
        cmp r12, 0
        jnz need_to_add_to_buffer
        jmp not_need_to_add_to_buffer
        need_to_add_to_buffer:
            push rax
            mov rax, '0'
            add rax, rdi
            mov [rsi + r12], rax
            add r12, 1
            pop rax
        not_need_to_add_to_buffer:
        sub rax, 1

        push rax
        push rsi
        mov rsi, 10
        mov rax, rdx
		xor rdx, rdx
        div rsi
        mov rdx, rax
        pop rsi
        pop rax

        push rbx
        push rcx
        mov rcx, r15
        neg rcx
        shl rbx, cl
        pop rcx
        add rbx, rcx
        cmp rbx, r10
        jg not_return_from_fucntion
        pop rbx
        sub r13, rax
        jmp final_digit_gen

        not_return_from_fucntion:
        pop rbx
        jmp loop_it_not_zero
    final_loop_it_not_zero:

    complete_buffer_loop:
        push rax
        push rbx
        push rdx
        xor rdx, rdx
        mov rbx, 10
        mov rax, rcx
        mul rbx
        mov rcx, rax
        pop rdx
        pop rbx
        pop rax

        push rax
        push r15
        push rcx
        mov rax, rcx
        neg r15
        mov rcx, r15
        shr rax, cl
        mov rdi, rax
        pop rcx
        pop r15
        pop rax

        cmp rdi, 0
        jnz complete_need_to_add_to_buffer
        cmp r12, 0
        jnz complete_need_to_add_to_buffer
        jmp complete_not_need_to_add_to_buffer
        complete_need_to_add_to_buffer:
            push rax
            mov rax, '0'
            add rax, rdi
            mov [rsi + r12], rax
            add r12, 1
            pop rax
        complete_not_need_to_add_to_buffer:
        sub rax, 1

        push r14
        sub r14, 1
        and rcx, r14
        pop r14

        push rax
        push rbx
        mov rax, r10
        mov rbx, 10
        mul rbx
        mov r10, rax
        pop rbx
        pop rax

        cmp rcx, r10
        jg complete_buffer_loop

    sub r13, rax
    final_digit_gen:
	pop r15
    ret

;--------------------------------------------------------------------------------------------------
; rdi - number
; rax, rbx - fundamental structure for this method
; r8, r9 - return values
get_ok_structure:
    push r11
    push r12
    push rax
    push rbx
	push rdx

    call construct_it
    mov r10, r8
    mov r11, r9
    mov r12, rax
    mov r13, rbx
    call sum

    shr r8, 1
    ; now in r8 and r9 stores div2(sum(v_help, w))


    mov rax, qword gen
    mov rbx, r15
    add rbx, 400
    add rbx, rbx
    mov r12, [rax + rbx * 8]
    mov r13, [rax + rbx * 8 + 8]
    mov r10, r8
    mov r11, r9
    call multiply
	
	pop rdx
    pop rbx
    pop rax
    pop r12
    pop r11
    ret

;--------------------------------------------------------------------------------------------------
global dbl2str
; r15 - mk
; r11, r12 - M_plus
; r13, r14 - M_minus

dbl2str:
    push rbp
    mov rbp, rsp
    
    ; allignment
    and rsp, -16
	mov rdi, [rcx]
	mov rax, 1
	shl rax, 63
	and rax, rdi
	cmp rax, 0
	jz write_plus
	mov rax, '-'
	mov [rdx], rax
	add rdx, 1
	jmp sign_written

	write_plus:
	mov rax, '+'
	mov [rdx], rax
	add rdx, 1
	sign_written:

	mov rdi, [rcx]
	mov rax, 1
	shl rax, 63
	not rax
	and rdi, rax
	mov rax, [order_all_one]
	mov rbx, [order_all_one]
	and rbx, rdi
	cmp rbx, rax
	jne not_handle_inf_or_nan
	cmp rax, rdi
	je handle_inf
	jmp handle_nan
	not_handle_inf_or_nan:


	mov rax, '0'
	mov [rdx], rax
	add rdx, 1
	mov rax, '.'
	mov [rdx], rax
	add rdx, 1


    ; w
    mov rdi, [rcx]
	mov rax, 1
	shl rax, 63
	not rax
	and rdi, rax
	cmp rdi, 0
	je handle_zero_case

    call construct_it
    mov rax, qword mks
    mov rbx, r9
    add rbx, 800
    mov r15, [rax + rbx * 8]
    mov rax, r8
    mov rbx, r9

    ; M_plus
    add rdi, 1
    call get_ok_structure
    mov r11, r8
    mov r12, r9
    add r11, 1

    ; M_minus
    sub rdi, 2
    call get_ok_structure
    mov r13, r8
    mov r14, r9
    sub r13, 1

	mov rax, r11
	mov rbx, r12
    mov r10, r11
    mov r11, r12
    mov r12, r13
    mov r13, r14
    call minus
	mov r11, rax
	mov r12, rbx

	mov r13, r11
	mov r14, r12

    ; delta
    mov r10, r8
    mov r11, r9
	; M_plus
	mov r8, r13
    mov r9, r14
    ; K
    mov r13, r15
    ; buffer
    mov rsi, rdx ; just to convince
    ; len
    mov r12, 0
	call get_chars

	neg r13
	add r13, r12

	mov rax, 'e'
	mov [rsi + r12], rax
	add r12, 1

	cmp r13, 0
	jge exp_is_positive
	mov rax, '-'
	mov [rsi + r12], rax
	add r12, 1
	neg r13
	exp_is_positive:

	; length
	mov rdi, 0
	mov rcx, qword exp
	parse_exp:
		xor rdx, rdx
		mov rax, r13
		mov rbx, 10
		div rbx
		add rdx, '0'
		mov [rcx], rdx
		add rdi, 1
		add rcx, 1
		mov r13, rax
		cmp rax, 0
		jne parse_exp

	add rsi, r12
	sub rcx, 1
	write_from_parsed:
		mov rax, [rcx]
		mov [rsi], al
		add r12, 1
		sub rcx, 1
		add rsi, 1
		sub rdi, 1
		jnz write_from_parsed

	mov rax, 0
	mov [rsi + r12], rax
	add r12, 1
	jmp total_final

	handle_zero_case:
	mov r12, 0
	mov rax, '0'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 'e'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, '0'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 0
	mov [rdx + r12], rax
	add r12, 1
	jmp total_final

	handle_nan:
	mov r12, -1
	mov rax, 'n'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 'a'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 'n'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 0
	mov [rdx + r12], rax
	add r12, 1
	jmp total_final

	handle_inf:
	mov r12, 0
	mov rax, 'i'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 'n'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 'f'
	mov [rdx + r12], rax
	add r12, 1
	mov rax, 0
	mov [rdx + r12], rax
	add r12, 1
	jmp total_final



	total_final:
    ; restore rsp & rbp
    mov rsp, rbp
    pop rbp
    ret

section .data
	exp times 1000 db 0

section .rodata
    format_d db "%lld ", 10, 0
	order_all_one dq 9218868437227405312


    gen dq  1351026840954986335, -1389, 1688783551193732919, -1386, 2110979438992166148, -1383, 1319362149370103843, -1379, 1649202686712629803, -1376, 2061503358390787254, -1373, 1288439598994242034, -1369, 1610549498742802542, -1366, 2013186873428503178, -1363, 1258241795892814486, -1359, 1572802244866018108, -1356, 1966002806082522635, -1353, 1228751753801576647, -1349, 1535939692251970808, -1346, 1919924615314963510, -1343, 1199952884571852194, -1339, 1499941105714815242, -1336, 1874926382143519053, -1333, 1171828988839699408, -1329, 1464786236049624260, -1326, 1830982795062030325, -1323, 2288728493827537907, -1320, 1430455308642211192, -1316, 1788069135802763990, -1313, 2235086419753454987, -1310, 1396929012345909367, -1306, 1746161265432386709, -1303, 2182701581790483386, -1300, 1364188488619052116, -1296, 1705235610773815145, -1293, 2131544513467268931, -1290, 1332215320917043082, -1286, 1665269151146303853, -1283, 2081586438932879816, -1280, 1300991524333049885, -1276, 1626239405416312356, -1273, 2032799256770390445, -1270, 1270499535481494028, -1266, 1588124419351867535, -1263, 1985155524189834419, -1260, 1240722202618646512, -1256, 1550902753273308140, -1253, 1938628441591635175, -1250, 1211642775994771984, -1246, 1514553469993464980, -1243, 1893191837491831225, -1240, 1183244898432394516, -1236, 1479056123040493145, -1233, 1848820153800616431, -1230, 1155512596125385269, -1226, 1444390745156731587, -1223, 1805488431445914484, -1220, 2256860539307393105, -1217, 1410537837067120690, -1213, 1763172296333900863, -1210, 2203965370417376079, -1207, 1377478356510860049, -1203, 1721847945638575061, -1200, 2152309932048218827, -1197, 1345193707530136767, -1193, 1681492134412670958, -1190, 2101865168015838698, -1187, 1313665730009899186, -1183, 1642082162512373983, -1180, 2052602703140467478, -1177, 1282876689462792174, -1173, 1603595861828490217, -1170, 2004494827285612772, -1167, 1252809267053507982, -1163, 1566011583816884978, -1160, 1957514479771106223, -1157, 1223446549856941389, -1153, 1529308187321176736, -1150, 1911635234151470921, -1147, 1194772021344669325, -1143, 1493465026680836657, -1140, 1866831283351045821, -1137, 1166769552094403638, -1133, 1458461940118004547, -1130, 1823077425147505684, -1127, 2278846781434382106, -1124, 1424279238396488816, -1120, 1780349047995611020, -1117, 2225436309994513775, -1114, 1390897693746571109, -1110, 1738622117183213887, -1107, 2173277646479017358, -1104, 1358298529049385849, -1100, 1697873161311732311, -1097, 2122341451639665389, -1094, 1326463407274790868, -1090, 1658079259093488585, -1087, 2072599073866860731, -1084, 1295374421166787957, -1080, 1619218026458484946, -1077, 2024022533073106183, -1074, 1265014083170691364, -1070, 1581267603963364205, -1067, 1976584504954205257, -1064, 1235365315596378285, -1060, 1544206644495472857, -1057, 1930258305619341071, -1054, 1206411441012088169, -1050, 1508014301265110212, -1047, 1885017876581387765, -1044, 1178136172863367353, -1040, 1472670216079209191, -1037, 1840837770099011489, -1034, 2301047212623764361, -1031, 1438154507889852726, -1027, 1797693134862315907, -1024, 2247116418577894884, -1021, 1404447761611184302, -1017, 1755559702013980378, -1014, 2194449627517475473, -1011, 1371531017198422170, -1007, 1714413771498027713, -1004, 2143017214372534641, -1001, 1339385758982834151, -997, 1674232198728542688, -994, 2092790248410678361, -991, 1307993905256673975, -987, 1634992381570842469, -984, 2043740476963553087, -981, 1277337798102220679, -977, 1596672247627775849, -974, 1995840309534719811, -971, 1247400193459199882, -967, 1559250241823999852, -964, 1949062802279999816, -961, 1218164251424999885, -957, 1522705314281249856, -954, 1903381642851562320, -951, 1189613526782226450, -947, 1487016908477783062, -944, 1858771135597228828, -941, 1161731959748268017, -937, 1452164949685335022, -934, 1815206187106668777, -931, 2269007733883335972, -928, 1418129833677084982, -924, 1772662292096356228, -921, 2215827865120445285, -918, 1384892415700278303, -914, 1731115519625347879, -911, 2163894399531684849, -908, 1352433999707303030, -904, 1690542499634128788, -901, 2113178124542660985, -898, 1320736327839163115, -894, 1650920409798953894, -891, 2063650512248692368, -888, 1289781570155432730, -884, 1612226962694290912, -881, 2015283703367863641, -878, 1259552314604914775, -874, 1574440393256143469, -871, 1968050491570179337, -868, 1230031557231362085, -864, 1537539446539202607, -861, 1921924308174003258, -858, 1201202692608752036, -854, 1501503365760940045, -851, 1876879207201175057, -848, 1173049504500734410, -844, 1466311880625918013, -841, 1832889850782397517, -838, 2291112313477996896, -835, 1431945195923748060, -831, 1789931494904685075, -828, 2237414368630856344, -825, 1398383980394285215, -821, 1747979975492856518, -818, 2184974969366070648, -815, 1365609355853794155, -811, 1707011694817242694, -808, 2133764618521553367, -805, 1333602886575970854, -801, 1667003608219963568, -798, 2083754510274954460, -795, 1302346568921846537, -791, 1627933211152308172, -788, 2034916513940385215, -785, 1271822821212740759, -781, 1589778526515925949, -778, 1987223158144907436, -775, 1242014473840567148, -771, 1552518092300708935, -768, 1940647615375886168, -765, 1212904759609928855, -761, 1516130949512411069, -758, 1895163686890513836, -755, 1184477304306571148, -751, 1480596630383213935, -748, 1850745787979017418, -745, 1156716117486885886, -741, 1445895146858607358, -738, 1807368933573259198, -735, 2259211166966573997, -732, 1412006979354108748, -728, 1765008724192635935, -725, 2206260905240794919, -722, 1378913065775496824, -718, 1723641332219371030, -715, 2154551665274213788, -712, 1346594790796383617, -708, 1683243488495479522, -705, 2104054360619349402, -702, 1315033975387093376, -698, 1643792469233866721, -695, 2054740586542333401, -692, 1284212866588958375, -688, 1605266083236197969, -685, 2006582604045247462, -682, 1254114127528279663, -678, 1567642659410349579, -675, 1959553324262936974, -672, 1224720827664335609, -668, 1530901034580419511, -665, 1913626293225524389, -662, 1196016433265952743, -658, 1495020541582440929, -655, 1868775676978051161, -652, 1167984798111281975, -648, 1459980997639102469, -645, 1824976247048878087, -642, 2281220308811097609, -639, 1425762693006936005, -635, 1782203366258670007, -632, 2227754207823337509, -629, 1392346379889585943, -625, 1740432974861982428, -622, 2175541218577478036, -619, 1359713261610923772, -615, 1699641577013654715, -612, 2124551971267068394, -609, 1327844982041917746, -605, 1659806227552397183, -602, 2074757784440496479, -599, 1296723615275310299, -595, 1620904519094137874, -592, 2026130648867672343, -589, 1266331655542295214, -585, 1582914569427869017, -582, 1978643211784836272, -579, 1236652007365522670, -575, 1545815009206903337, -572, 1932268761508629172, -569, 1207667975942893232, -565, 1509584969928616540, -562, 1886981212410770676, -559, 1179363257756731672, -555, 1474204072195914590, -552, 1842755090244893238, -549, 2303443862806116547, -546, 1439652414253822842, -542, 1799565517817278553, -539, 2249456897271598191, -536, 1405910560794748869, -532, 1757388200993436087, -529, 2196735251241795108, -526, 1372959532026121942, -522, 1716199415032652428, -519, 2145249268790815535, -516, 1340780792994259709, -512, 1675975991242824637, -509, 2094969989053530796, -506, 1309356243158456748, -502, 1636695303948070935, -499, 2045869129935088668, -496, 1278668206209430417, -492, 1598335257761788022, -489, 1997919072202235028, -486, 1248699420126396892, -482, 1560874275157996115, -479, 1951092843947495144, -476, 1219433027467184465, -472, 1524291284333980581, -469, 1905364105417475727, -466, 1190852565885922329, -462, 1488565707357402911, -459, 1860707134196753639, -456, 1162941958872971024, -452, 1453677448591213781, -449, 1817096810739017226, -446, 2271371013423771532, -443, 1419606883389857208, -439, 1774508604237321510, -436, 2218135755296651887, -433, 1386334847060407429, -429, 1732918558825509287, -426, 2166148198531886609, -423, 1353842624082429130, -419, 1692303280103036413, -416, 2115379100128795516, -413, 1322111937580497197, -409, 1652639921975621497, -406, 2065799902469526871, -403, 1291124939043454294, -399, 1613906173804317868, -396, 2017382717255397335, -393, 1260864198284623334, -389, 1576080247855779168, -386, 1970100309819723960, -383, 1231312693637327475, -379, 1539140867046659344, -376, 1923926083808324180, -373, 1202453802380202612, -369, 1503067252975253265, -366, 1878834066219066582, -363, 1174271291386916613, -359, 1467839114233645767, -356, 1834798892792057209, -353, 2293498615990071511, -350, 1433436634993794694, -346, 1791795793742243368, -343, 2239744742177804210, -340, 1399840463861127631, -336, 1749800579826409539, -333, 2187250724783011924, -330, 1367031702989382452, -326, 1708789628736728065, -323, 2135987035920910082, -320, 1334991897450568801, -316, 1668739871813211001, -313, 2085924839766513752, -310, 1303703024854071095, -306, 1629628781067588869, -303, 2037035976334486086, -300, 1273147485209053803, -296, 1591434356511317254, -293, 1989292945639146568, -290, 1243308091024466605, -286, 1554135113780583256, -283, 1942668892225729070, -280, 1214168057641080669, -276, 1517710072051350836, -273, 1897137590064188545, -270, 1185710993790117841, -266, 1482138742237647301, -263, 1852673427797059126, -260, 1157920892373161954, -256, 1447401115466452442, -253, 1809251394333065553, -250, 2261564242916331941, -247, 1413477651822707463, -243, 1766847064778384329, -240, 2208558830972980411, -237, 1380349269358112757, -233, 1725436586697640946, -230, 2156795733372051183, -227, 1347997333357531989, -223, 1684996666696914987, -220, 2106245833371143733, -217, 1316403645856964833, -213, 1645504557321206042, -210, 2056880696651507552, -207, 1285550435407192220, -203, 1606938044258990275, -200, 2008672555323737844, -197, 1255420347077336152, -193, 1569275433846670190, -190, 1961594292308337738, -187, 1225996432692711086, -183, 1532495540865888858, -180, 1915619426082361072, -177, 1197262141301475670, -173, 1496577676626844588, -170, 1870722095783555735, -167, 1169201309864722334, -163, 1461501637330902918, -160, 1826877046663628647, -157, 2283596308329535809, -154, 1427247692705959881, -150, 1784059615882449851, -147, 2230074519853062314, -144, 1393796574908163946, -140, 1742245718635204932, -137, 2177807148294006166, -134, 1361129467683753853, -130, 1701411834604692317, -127, 2126764793255865396, -124, 1329227995784915872, -120, 1661534994731144841, -117, 2076918743413931051, -114, 1298074214633706907, -110, 1622592768292133633, -107, 2028240960365167042, -104, 1267650600228229401, -100, 1584563250285286751, -97, 1980704062856608439, -94, 1237940039285380274, -90, 1547425049106725343, -87, 1934281311383406679, -84, 1208925819614629174, -80, 1511157274518286468, -77, 1888946593147858085, -74, 1180591620717411303, -70, 1475739525896764129, -67, 1844674407370955161, -64, 2305843009213693951, -61, 1441151880758558719, -57, 1801439850948198399, -54, 2251799813685247999, -51, 1407374883553279999, -47, 1759218604441599999, -44, 2199023255551999999, -41, 1374389534719999999, -37, 1717986918399999999, -34, 2147483647999999999, -31, 1342177279999999999, -27, 1677721599999999999, -24, 2097151999999999999, -21, 1310719999999999999, -17, 1638399999999999999, -14, 2047999999999999999, -11, 1279999999999999999, -7, 1599999999999999999, -4, 1999999999999999999, -1, 1249999999999999999, 3, 1562499999999999999, 6, 1953124999999999999, 9, 1220703124999999999, 13, 1525878906249999999, 16, 1907348632812499999, 19, 1192092895507812499, 23, 1490116119384765624, 26, 1862645149230957031, 29, 1164153218269348144, 33, 1455191522836685180, 36, 1818989403545856475, 39, 2273736754432320594, 42, 1421085471520200371, 46, 1776356839400250464, 49, 2220446049250313080, 52, 1387778780781445675, 56, 1734723475976807094, 59, 2168404344971008868, 62, 1355252715606880542, 66, 1694065894508600678, 69, 2117582368135750847, 72, 1323488980084844279, 76, 1654361225106055349, 79, 2067951531382569187, 82, 1292469707114105741, 86, 1615587133892632177, 89, 2019483917365790221, 92, 1262177448353618888, 96, 1577721810442023610, 99, 1972152263052529513, 102, 1232595164407830945, 106, 1540743955509788682, 109, 1925929944387235853, 112, 1203706215242022408, 116, 1504632769052528010, 119, 1880790961315660012, 122, 1175494350822287507, 126, 1469367938527859384, 129, 1836709923159824231, 132, 2295887403949780289, 135, 1434929627468612680, 139, 1793662034335765850, 142, 2242077542919707313, 145, 1401298464324817070, 149, 1751623080406021338, 152, 2189528850507526673, 155, 1368455531567204170, 159, 1710569414459005213, 162, 2138211768073756516, 165, 1336382355046097823, 169, 1670477943807622278, 172, 2088097429759527848, 175, 1305060893599704905, 179, 1631326116999631131, 182, 2039157646249538914, 185, 1274473528905961821, 189, 1593091911132452277, 192, 1991364888915565346, 195, 1244603055572228341, 199, 1555753819465285426, 202, 1944692274331606783, 205, 1215432671457254239, 209, 1519290839321567799, 212, 1899113549151959749, 215, 1186945968219974843, 219, 1483682460274968554, 222, 1854603075343710692, 225, 1159126922089819183, 229, 1448908652612273978, 232, 1811135815765342473, 235, 2263919769706678091, 238, 1414949856066673807, 242, 1768687320083342259, 245, 2210859150104177824, 248, 1381786968815111140, 252, 1727233711018888925, 255, 2159042138773611156, 258, 1349401336733506972, 262, 1686751670916883715, 265, 2108439588646104644, 268, 1317774742903815403, 272, 1647218428629769253, 275, 2059023035787211567, 278, 1286889397367007229, 282, 1608611746708759036, 285, 2010764683385948796, 288, 1256727927116217997, 292, 1570909908895272496, 295, 1963637386119090621, 298, 1227273366324431638, 302, 1534091707905539547, 305, 1917614634881924434, 308, 1198509146801202771, 312, 1498136433501503464, 315, 1872670541876879330, 318, 1170419088673049581, 322, 1463023860841311977, 325, 1828779826051639971, 328, 2285974782564549964, 331, 1428734239102843727, 335, 1785917798878554659, 338, 2232397248598193324, 341, 1395248280373870827, 345, 1744060350467338534, 348, 2180075438084173168, 351, 1362547148802608230, 355, 1703183936003260287, 358, 2128979920004075359, 361, 1330612450002547099, 365, 1663265562503183874, 368, 2079081953128979843, 371, 1299426220705612402, 375, 1624282775882015502, 378, 2030353469852519378, 381, 1268970918657824611, 385, 1586213648322280764, 388, 1982767060402850955, 391, 1239229412751781847, 395, 1549036765939727309, 398, 1936295957424659136, 401, 1210184973390411960, 405, 1512731216738014950, 408, 1890914020922518687, 411, 1181821263076574179, 415, 1477276578845717724, 418, 1846595723557147156, 421, 1154122327223216972, 425, 1442652909029021215, 428, 1803316136286276519, 431, 2254145170357845649, 434, 1408840731473653530, 438, 1761050914342066913, 441, 2201313642927583642, 444, 1375821026829739776, 448, 1719776283537174720, 451, 2149720354421468400, 454, 1343575221513417750, 458, 1679469026891772187, 461, 2099336283614715234, 464, 1312085177259197021, 468, 1640106471573996277, 471, 2050133089467495346, 474, 1281333180917184591, 478, 1601666476146480739, 481, 2002083095183100924, 484, 1251301934489438077, 488, 1564127418111797597, 491, 1955159272639746996, 494, 1221974545399841872, 498, 1527468181749802341, 501, 1909335227187252926, 504, 1193334516992033078, 508, 1491668146240041348, 511, 1864585182800051685, 514, 1165365739250032303, 518, 1456707174062540379, 521, 1820883967578175474, 524, 2276104959472719343, 527, 1422565599670449589, 531, 1778206999588061986, 534, 2222758749485077483, 537, 1389224218428173427, 541, 1736530273035216783, 544, 2170662841294020979, 547, 1356664275808763112, 551, 1695830344760953890, 554, 2119787930951192363, 557, 1324867456844495227, 561, 1656084321055619033, 564, 2070105401319523792, 567, 1293815875824702370, 571, 1617269844780877962, 574, 2021587305976097453, 577, 1263492066235060908, 581, 1579365082793826135, 584, 1974206353492282669, 587, 1233878970932676668, 591, 1542348713665845835, 594, 1927935892082307294, 597, 1204959932551442058, 601, 1506199915689302573, 604, 1882749894611628216, 607, 1176718684132267635, 611, 1470898355165334544, 614, 1838622943956668180, 617, 2298278679945835225, 620, 1436424174966147016, 624, 1795530218707683770, 627, 2244412773384604712, 630, 1402757983365377945, 634, 1753447479206722431, 637, 2191809349008403039, 640, 1369880843130251899, 644, 1712351053912814874, 647, 2140438817391018593, 650, 1337774260869386620, 654, 1672217826086733276, 657, 2090272282608416595, 660, 1306420176630260372, 664, 1633025220787825465, 667, 2041281525984781831, 670, 1275800953740488644, 674, 1594751192175610805, 677, 1993438990219513507, 680, 1245899368887195941, 684, 1557374211108994927, 687, 1946717763886243659, 690, 1216698602428902287, 694, 1520873253036127858, 697, 1901091566295159823, 700, 1188182228934474889, 704, 1485227786168093612, 707, 1856534732710117015, 710, 1160334207943823134, 714, 1450417759929778918, 717, 1813022199912223647, 720, 2266277749890279559, 723, 1416423593681424724, 727, 1770529492101780905, 730, 2213161865127226132, 733, 1383226165704516332, 737, 1729032707130645415, 740, 2161290883913306769, 743, 1350806802445816731, 747, 1688508503057270913, 750, 2110635628821588642, 753, 1319147268013492901, 757, 1648934085016866126, 760, 2061167606271082658, 763, 1288229753919426661, 767, 1610287192399283327, 770, 2012858990499104158, 773, 1258036869061940099, 777, 1572546086327425124, 780, 1965682607909281405, 783, 1228551629943300878, 787, 1535689537429126097, 790, 1919611921786407622, 793, 1199757451116504763, 797, 1499696813895630954, 800, 1874621017369538693, 803, 1171638135855961683, 807, 1464547669819952104, 810, 1830684587274940130, 813, 2288355734093675162, 816, 1430222333808546976, 820, 1787777917260683721, 823, 2234722396575854651, 826, 1396701497859909157, 830, 1745876872324886446, 833, 2182346090406108057, 836, 1363966306503817536, 840, 1704957883129771920, 843, 2131197353912214900, 846, 1331998346195134312, 850, 1664997932743917890, 853, 2081247415929897363, 856, 1300779634956185852, 860, 1625974543695232315, 863, 2032468179619040394, 866, 1270292612261900246, 870, 1587865765327375307, 873, 1984832206659219134, 876, 1240520129162011959, 880, 1550650161452514949, 883, 1938312701815643686, 886, 1211445438634777304, 890, 1514306798293471630, 893, 1892883497866839537, 896, 1183052186166774710, 900, 1478815232708468388, 903, 1848519040885585485, 906, 1155324400553490928, 910, 1444155500691863660, 913, 1805194375864829576, 916, 2256492969831036970, 919, 1410308106144398106, 923, 1762885132680497632, 926, 2203606415850622041, 929, 1377254009906638775, 933, 1721567512383298469, 936, 2151959390479123087, 939, 1344974619049451929, 943, 1681218273811814911, 946, 2101522842264768639, 949, 1313451776415480399, 953, 1641814720519350499, 956, 2052268400649188124, 959, 1282667750405742577, 963, 1603334688007178222, 966, 2004168360008972777, 969, 1252605225005607986, 973, 1565756531257009982, 976, 1957195664071262478, 979, 1223247290044539049, 983, 1529059112555673811, 986, 1911323890694592264, 989, 1194577431684120165, 993, 1493221789605150206, 996, 1866527237006437757, 999, 1166579523129023598, 1003, 1458224403911279498, 1006, 1822780504889099373, 1009, 2278475631111374216, 1012, 1424047269444608885, 1016, 1780059086805761106, 1019, 2225073858507201383, 1022, 1390671161567000864, 1026, 1738338951958751080, 1029, 2172923689948438850, 1032, 1358077306217774281, 1036, 1697596632772217852, 1039, 2121995790965272315, 1042, 1326247369353295196, 1046, 1657809211691618996, 1049, 2072261514614523745, 1052, 1295163446634077340, 1056, 1618954308292596675, 1059, 2023692885365745844, 1062, 1264808053353591153, 1066, 1581010066691988941, 1069, 1976262583364986176, 1072, 1235164114603116360, 1076, 1543955143253895450, 1079, 1929943929067369313, 1082, 1206214955667105820, 1086, 1507768694583882275, 1089, 1884710868229852844, 1092, 1177944292643658028, 1096, 1472430365804572535, 1099, 1840537957255715668, 1102, 2300672446569644586, 1105, 1437920279106027866, 1109, 1797400348882534832, 1112, 2246750436103168541, 1115, 1404219022564480338, 1119, 1755273778205600422, 1122, 2194092222757000528, 1125, 1371307639223125330, 1129, 1714134549028906662, 1132, 2142668186286133328, 1135, 1339167616428833330, 1139, 1673959520536041662, 1142, 2092449400670052078, 1145, 1307780875418782549, 1149, 1634726094273478186, 1152, 2043407617841847733, 1155, 1277129761151154833, 1159, 1596412201438943541, 1162, 1995515251798679426, 1165, 1247197032374174641, 1169, 1558996290467718302, 1172, 1948745363084647877, 1175, 1217965851927904923, 1179, 1522457314909881154, 1182, 1903071643637351443, 1185, 1189419777273344651, 1189, 1486774721591680814, 1192, 1858468401989601018, 1195, 1161542751243500636, 1199, 1451928439054375795, 1202, 1814910548817969744, 1205, 2268638186022462180, 1208, 1417898866264038863, 1212, 1772373582830048578, 1215, 2215466978537560723, 1218, 1384666861585975452, 1222, 1730833576982469315, 1225, 2163541971228086644, 1228, 1352213732017554152, 1232, 1690267165021942690, 1235, 2112833956277428363, 1238, 1320521222673392727, 1242, 1650651528341740908, 1245, 2063314410427176136, 1248, 1289571506516985085, 1252, 1611964383146231356, 1255, 2014955478932789195, 1258, 1259347174332993247, 1262, 1574183967916241558, 1265, 1967729959895301948, 1268  

    mks dq 223, 223, 223, 222, 222, 222, 221, 221, 221, 221, 220, 220, 220, 219, 219, 219, 218, 218, 218, 218, 217, 217, 217, 216, 216, 216, 215, 215, 215, 215, 214, 214, 214, 213, 213, 213, 212, 212, 212, 212, 211, 211, 211, 210, 210, 210, 209, 209, 209, 209, 208, 208, 208, 207, 207, 207, 206, 206, 206, 206, 205, 205, 205, 204, 204, 204, 203, 203, 203, 202, 202, 202, 202, 201, 201, 201, 200, 200, 200, 199, 199, 199, 199, 198, 198, 198, 197, 197, 197, 196, 196, 196, 196, 195, 195, 195, 194, 194, 194, 193, 193, 193, 193, 192, 192, 192, 191, 191, 191, 190, 190, 190, 190, 189, 189, 189, 188, 188, 188, 187, 187, 187, 187, 186, 186, 186, 185, 185, 185, 184, 184, 184, 184, 183, 183, 183, 182, 182, 182, 181, 181, 181, 181, 180, 180, 180, 179, 179, 179, 178, 178, 178, 178, 177, 177, 177, 176, 176, 176, 175, 175, 175, 174, 174, 174, 174, 173, 173, 173, 172, 172, 172, 171, 171, 171, 171, 170, 170, 170, 169, 169, 169, 168, 168, 168, 168, 167, 167, 167, 166, 166, 166, 165, 165, 165, 165, 164, 164, 164, 163, 163, 163, 162, 162, 162, 162, 161, 161, 161, 160, 160, 160, 159, 159, 159, 159, 158, 158, 158, 157, 157, 157, 156, 156, 156, 156, 155, 155, 155, 154, 154, 154, 153, 153, 153, 153, 152, 152, 152, 151, 151, 151, 150, 150, 150, 150, 149, 149, 149, 148, 148, 148, 147, 147, 147, 146, 146, 146, 146, 145, 145, 145, 144, 144, 144, 143, 143, 143, 143, 142, 142, 142, 141, 141, 141, 140, 140, 140, 140, 139, 139, 139, 138, 138, 138, 137, 137, 137, 137, 136, 136, 136, 135, 135, 135, 134, 134, 134, 134, 133, 133, 133, 132, 132, 132, 131, 131, 131, 131, 130, 130, 130, 129, 129, 129, 128, 128, 128, 128, 127, 127, 127, 126, 126, 126, 125, 125, 125, 125, 124, 124, 124, 123, 123, 123, 122, 122, 122, 122, 121, 121, 121, 120, 120, 120, 119, 119, 119, 119, 118, 118, 118, 117, 117, 117, 116, 116, 116, 115, 115, 115, 115, 114, 114, 114, 113, 113, 113, 112, 112, 112, 112, 111, 111, 111, 110, 110, 110, 109, 109, 109, 109, 108, 108, 108, 107, 107, 107, 106, 106, 106, 106, 105, 105, 105, 104, 104, 104, 103, 103, 103, 103, 102, 102, 102, 101, 101, 101, 100, 100, 100, 100, 99, 99, 99, 98, 98, 98, 97, 97, 97, 97, 96, 96, 96, 95, 95, 95, 94, 94, 94, 94, 93, 93, 93, 92, 92, 92, 91, 91, 91, 91, 90, 90, 90, 89, 89, 89, 88, 88, 88, 87, 87, 87, 87, 86, 86, 86, 85, 85, 85, 84, 84, 84, 84, 83, 83, 83, 82, 82, 82, 81, 81, 81, 81, 80, 80, 80, 79, 79, 79, 78, 78, 78, 78, 77, 77, 77, 76, 76, 76, 75, 75, 75, 75, 74, 74, 74, 73, 73, 73, 72, 72, 72, 72, 71, 71, 71, 70, 70, 70, 69, 69, 69, 69, 68, 68, 68, 67, 67, 67, 66, 66, 66, 66, 65, 65, 65, 64, 64, 64, 63, 63, 63, 63, 62, 62, 62, 61, 61, 61, 60, 60, 60, 60, 59, 59, 59, 58, 58, 58, 57, 57, 57, 56, 56, 56, 56, 55, 55, 55, 54, 54, 54, 53, 53, 53, 53, 52, 52, 52, 51, 51, 51, 50, 50, 50, 50, 49, 49, 49, 48, 48, 48, 47, 47, 47, 47, 46, 46, 46, 45, 45, 45, 44, 44, 44, 44, 43, 43, 43, 42, 42, 42, 41, 41, 41, 41, 40, 40, 40, 39, 39, 39, 38, 38, 38, 38, 37, 37, 37, 36, 36, 36, 35, 35, 35, 35, 34, 34, 34, 33, 33, 33, 32, 32, 32, 32, 31, 31, 31, 30, 30, 30, 29, 29, 29, 28, 28, 28, 28, 27, 27, 27, 26, 26, 26, 25, 25, 25, 25, 24, 24, 24, 23, 23, 23, 22, 22, 22, 22, 21, 21, 21, 20, 20, 20, 19, 19, 19, 19, 18, 18, 18, 17, 17, 17, 16, 16, 16, 16, 15, 15, 15, 14, 14, 14, 13, 13, 13, 13, 12, 12, 12, 11, 11, 11, 10, 10, 10, 10, 9, 9, 9, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, -3, -3, -4, -4, -4, -5, -5, -5, -6, -6, -6, -6, -7, -7, -7, -8, -8, -8, -9, -9, -9, -9, -10, -10, -10, -11, -11, -11, -12, -12, -12, -12, -13, -13, -13, -14, -14, -14, -15, -15, -15, -15, -16, -16, -16, -17, -17, -17, -18, -18, -18, -18, -19, -19, -19, -20, -20, -20, -21, -21, -21, -21, -22, -22, -22, -23, -23, -23, -24, -24, -24, -24, -25, -25, -25, -26, -26, -26, -27, -27, -27, -27, -28, -28, -28, -29, -29, -29, -30, -30, -30, -31, -31, -31, -31, -32, -32, -32, -33, -33, -33, -34, -34, -34, -34, -35, -35, -35, -36, -36, -36, -37, -37, -37, -37, -38, -38, -38, -39, -39, -39, -40, -40, -40, -40, -41, -41, -41, -42, -42, -42, -43, -43, -43, -43, -44, -44, -44, -45, -45, -45, -46, -46, -46, -46, -47, -47, -47, -48, -48, -48, -49, -49, -49, -49, -50, -50, -50, -51, -51, -51, -52, -52, -52, -52, -53, -53, -53, -54, -54, -54, -55, -55, -55, -55, -56, -56, -56, -57, -57, -57, -58, -58, -58, -59, -59, -59, -59, -60, -60, -60, -61, -61, -61, -62, -62, -62, -62, -63, -63, -63, -64, -64, -64, -65, -65, -65, -65, -66, -66, -66, -67, -67, -67, -68, -68, -68, -68, -69, -69, -69, -70, -70, -70, -71, -71, -71, -71, -72, -72, -72, -73, -73, -73, -74, -74, -74, -74, -75, -75, -75, -76, -76, -76, -77, -77, -77, -77, -78, -78, -78, -79, -79, -79, -80, -80, -80, -80, -81, -81, -81, -82, -82, -82, -83, -83, -83, -83, -84, -84, -84, -85, -85, -85, -86, -86, -86, -86, -87, -87, -87, -88, -88, -88, -89, -89, -89, -90, -90, -90, -90, -91, -91, -91, -92, -92, -92, -93, -93, -93, -93, -94, -94, -94, -95, -95, -95, -96, -96, -96, -96, -97, -97, -97, -98, -98, -98, -99, -99, -99, -99, -100, -100, -100, -101, -101, -101, -102, -102, -102, -102, -103, -103, -103, -104, -104, -104, -105, -105, -105, -105, -106, -106, -106, -107, -107, -107, -108, -108, -108, -108, -109, -109, -109, -110, -110, -110, -111, -111, -111, -111, -112, -112, -112, -113, -113, -113, -114, -114, -114, -114, -115, -115, -115, -116, -116, -116, -117, -117, -117, -118, -118, -118, -118, -119, -119, -119, -120, -120, -120, -121, -121, -121, -121, -122, -122, -122, -123, -123, -123, -124, -124, -124, -124, -125, -125, -125, -126, -126, -126, -127, -127, -127, -127, -128, -128, -128, -129, -129, -129, -130, -130, -130, -130, -131, -131, -131, -132, -132, -132, -133, -133, -133, -133, -134, -134, -134, -135, -135, -135, -136, -136, -136, -136, -137, -137, -137, -138, -138, -138, -139, -139, -139, -139, -140, -140, -140, -141, -141, -141, -142, -142, -142, -142, -143, -143, -143, -144, -144, -144, -145, -145, -145, -145, -146, -146, -146, -147, -147, -147, -148, -148, -148, -149, -149, -149, -149, -150, -150, -150, -151, -151, -151, -152, -152, -152, -152, -153, -153, -153, -154, -154, -154, -155, -155, -155, -155, -156, -156, -156, -157, -157, -157, -158, -158, -158, -158, -159, -159, -159, -160, -160, -160, -161, -161, -161, -161, -162, -162, -162, -163, -163, -163, -164, -164, -164, -164, -165, -165, -165, -166, -166, -166, -167, -167, -167, -167, -168, -168, -168, -169, -169, -169, -170, -170, -170, -170, -171, -171, -171, -172, -172, -172, -173, -173, -173, -173, -174, -174, -174, -175, -175, -175, -176, -176, -176, -177, -177, -177, -177, -178, -178, -178, -179, -179, -179, -180, -180, -180, -180, -181, -181, -181, -182, -182, -182, -183, -183, -183, -183, -184, -184, -184, -185, -185, -185, -186, -186, -186, -186, -187, -187, -187, -188, -188, -188, -189, -189, -189, -189, -190, -190, -190, -191, -191, -191, -192, -192, -192, -192, -193, -193, -193, -194, -194, -194, -195, -195, -195, -195, -196, -196, -196, -197, -197, -197, -198, -198, -198, -198, -199, -199, -199, -200, -200, -200, -201, -201, -201, -201, -202, -202, -202, -203, -203, -203, -204, -204, -204, -205, -205, -205, -205, -206, -206, -206, -207, -207, -207, -208, -208, -208, -208, -209, -209, -209, -210, -210, -210, -211, -211, -211, -211, -212, -212, -212, -213, -213, -213, -214, -214, -214, -214, -215, -215, -215, -216, -216, -216, -217, -217, -217, -217, -218, -218, -218, -219, -219, -219, -220, -220, -220, -220, -221, -221, -221, -222, -222, -222, -223, -223, -223, -223, -224, -224, -224, -225, -225, -225, -226, -226, -226, -226, -227, -227, -227, -228, -228, -228, -229, -229, -229, -229, -230, -230, -230, -231, -231, -231, -232, -232, -232, -232, -233, -233, -233, -234, -234, -234, -235, -235, -235, -236, -236, -236, -236, -237, -237, -237, -238, -238, -238, -239, -239, -239, -239, -240, -240, -240, -241, -241, -241, -242, -242, -242, -242, -243, -243, -243, -244, -244, -244, -245, -245, -245, -245, -246, -246, -246, -247, -247, -247, -248, -248, -248, -248, -249, -249, -249, -250, -250, -250, -251, -251, -251, -251, -252, -252, -252, -253, -253, -253, -254, -254, -254, -254, -255, -255, -255, -256, -256, -256, -257, -257, -257, -257, -258, -258

    end