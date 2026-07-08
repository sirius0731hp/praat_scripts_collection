#############################
##Phonetics Lab at CityUHK###
##Yijing.HE@my.cityu.edu.hk##
#############################


form Settings
    comment 1. Set the possible range of consonantal A1 / nasal murmur peak in Hz.

    real lowFreqC 100
    real highFreqC 400

    comment 2. Enter the tier number of the target tier in the TextGrid.

    real tierNum 1

    comment 3. Enter the interval number of the target consonant in the TextGrid.

    real intNum 2

    comment 4. Enter the relative time points within the target intervals, from 0 to 1.

    real consonantTime 0.5
    real vowelTime 0.25

    comment 5. Choose the gender of the speaker.

    optionmenu gender: 2
        option Male
        option Female
endform


clearinfo 

###################
##Variable

askBeforeDelete = 1 
#1 = ask before overwriting existing output file; 0 = overwrite directly

if gender = 1
    maxF = 5000
else
    maxF = 5500
endif

fNum = 5

# Function: Extract A1 and calculate Delta A1
# Textgrid: | |Consontant|Vowel| |
# Praat version used: 6.4.62 (March 13, 2026)

###################
##IN and OUT
inDir$ = chooseDirectory$: "Select the folder containing matching WAV and TextGrid files."

inDir$ = inDir$ + "/"
inDirWav$ = inDir$ + "*.wav"

outDir$ = inDir$ + "output/"
outPath$ = outDir$ + "DeltaA1.tsv"

createDirectory: outDir$

if askBeforeDelete and fileReadable: outPath$
    pauseScript: "The data already exist. Overwrite?"
endif
deleteFile: outPath$


####################
##Spreadsheet Head
sep$ = tab$

header$ = "fileName" + sep$ 
... + "A1 consonant" + sep$
... + "A1 consonant timepoint" + sep$  
... + "F1 vowel" + sep$ 
... + "A1 vowel" + sep$ 
... + "A1 vowel timepoint" + sep$ 
... + "Delta A1" + newline$

appendFile: outPath$, header$


####################
##Main Loop
wavList = Create Strings as file list: "wavList", inDirWav$    

numFiles = Get number of strings

if numFiles == 0
	exitScript: "No WAV files were found in the folder. Exiting."
endif

for fileNum from 1 to numFiles

    selectObject: wavList
    wavName$ = Get string: fileNum
    appendInfoLine: wavName$

    wavPath$ = inDir$ + wavName$
    appendInfoLine: wavPath$
    wav = Read from file: wavPath$

    objName$ = selected$: "Sound"

    tgPath$ = inDir$ + objName$ + ".TextGrid"

    if fileReadable(tgPath$)
        tg = Read from file: tgPath$
    else
        printline: "File not found: ", tgPath$
    endif

    selectObject: tg
    label$ = Get label of interval: tierNum, intNum

        if label$ <> ""

            begC = Get start time of interval: tierNum, intNum
            endC = Get end time of interval: tierNum, intNum
            endV = Get end time of interval: tierNum, (intNum + 1)

            tpC = begC + ((endC - begC) * consonantTime)

            tpV = endC + ((endV - endC) * vowelTime)
                        
            selectObject: wav
            spectrogram = To Spectrogram: 0.03, maxF, 0.002, 20, "Gaussian"
            slice_tpC = To Spectrum (slice): tpC
            ltas_tpC = To Ltas (1-to-1)
            a1_tpC = Get maximum: lowFreqC, highFreqC, "parabolic"

            selectObject: wav
            formant = To Formant (burg): 0, fNum, maxF, 0.025, 50
            f1_v = Get value at time: 1, tpV, "hertz", "linear"

            selectObject: spectrogram
            slice_tpV = To Spectrum (slice): tpV
            ltas_tpV = To Ltas (1-to-1)
            a1_tpV = Get value at frequency: f1_v, "nearest"

            delta_a1 = a1_tpC - a1_tpV

            a1C$ = fixed$: a1_tpC, 8
            a1V$ = fixed$: a1_tpV, 8 
            delta_a1$ = fixed$: delta_a1, 8
            tpC$ = fixed$: tpC, 8
            tpV$ = fixed$: tpV, 8
            f1V$ = fixed$: f1_v, 8
                    
            dataRow$ = wavName$ + sep$
                ... + a1C$ + sep$
                ... + tpC$ + sep$
                ... + f1V$ + sep$
                ... + a1V$ + sep$
                ... + tpV$ +sep$
                ... + delta_a1$ + newline$

            appendFile: outPath$, dataRow$
                    
            removeObject: spectrogram
            removeObject: formant
            removeObject: slice_tpC
            removeObject: slice_tpV
            removeObject: ltas_tpC
            removeObject: ltas_tpV

        endif

  removeObject: wav
	removeObject: tg


endfor

removeObject: wavList

writeInfoLine: "Script finished successfully. Results saved in: ", outPath$
