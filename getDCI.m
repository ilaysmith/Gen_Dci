% gen dci format 1_0 SI-RNTI 
function dci = getDCI( ...
    FDMA,                         ... % Frequency domain resource assignment log2[Nrb(Nrb+1)]/2, Nrb - size crst 0. 
    TDMA,                         ... % Time domain resource assignment. 38.214 table 5.1.2.1.1-1 ->  5.1.2.1.1-2. 4 bits
    VrbPrb,                       ... % VRB-to-PRB mapping. 0 - non - interleaved, 1 - interleaved
    modulation_and_coding_scheme, ...% Modulation and coding scheme
    redundancy_Version,           ...              
    sII,                          ...% System Information Indicator 0 : SIB 1 and 1 : SI messages        
    reserved_bits                 ... % reversed bits. 15 bits 
    )

arguments
    FDMA (1,1) % integer
    TDMA (1,1) % integer
    VrbPrb (1,1){mustBeMember(VrbPrb, [0,1])}
    modulation_and_coding_scheme (1,1)
    redundancy_Version (1,1) % integer
    sII (1,1){mustBeMember(sII, [0,1])}
    reserved_bits = 0; % zeros(0,15)

end 

bFDMA = int2bit(FDMA,4).';
bTDMA = int2bit(TDMA,4).';
bMACS = int2bit(modulation_and_coding_scheme,5).';
bRV = int2bit(redundancy_Version,2).';
bRB = int2bit(reserved_bits,15).'; % zeros(0,15)

dci = [bFDMA bTDMA VrbPrb bMACS bRV sII bRB];

end







