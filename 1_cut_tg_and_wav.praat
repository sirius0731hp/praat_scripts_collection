#############################
##Phonetics Lab at CityUHK###
##yijing.he@my.cityu.edu.hk##
#############################

clearinfo 

###################
##Variable

leftMargin = 0.05
rightMargin = 0.05
#前后留多少空白 请都写正数

tierNum = 1
#选择textgrid的层数

#功能：根据textgrid切取标注范围内的textgrid和wav文件
#提示：所选文件夹内的子文件夹output里面内容会清空后再保存
#当前Praat版本为version 6.4.62（March 13，2026）

###################
##IN and OUT
inDir$ = chooseDirectory$: "请选择包含wav文件和同名textgrid的文件夹"

inDir$ = inDir$ + "/"
inDirWav$ = inDir$ + "*.wav"

outDir$ = inDir$ + "output/"
outPath$ = outDir$ + "*.wav"

createDirectory: outDir$

oldWavs = Create Strings as file list: "oldWavs", outDir$ + "*.wav"
nOldWavs = Get number of strings

for i from 1 to nOldWavs
    selectObject: oldWavs
    oldFile$ = Get string: i
    deleteFile: outDir$ + oldFile$
endfor

removeObject: oldWavs


oldTgs = Create Strings as file list: "oldTgs", outDir$ + "*.TextGrid"
nOldTgs = Get number of strings

for i from 1 to nOldTgs
    selectObject: oldTgs
    oldFile$ = Get string: i
    deleteFile: outDir$ + oldFile$
endfor

removeObject: oldTgs

####################
##Main Loop
wavList = Create Strings as file list: "wavList", inDirWav$    

numFiles = Get number of strings

if numFiles == 0
	exitScript: "文件夹中不存在wav文件 退出"
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

    numInts = Get number of intervals: tierNum

    count = 0

    for intNum from 1 to (numInts - 1)

        selectObject: tg

        labelC$ = Get label of interval: tierNum, intNum

        if labelC$ <> ""

            if right$ (labelC$, 2) = "_c"
                cvBase$ = left$ (labelC$, length(labelC$) - 2)
                    
                nextInt = intNum + 1

                labelV$ = Get label of interval: tierNum, nextInt
                expectedV$ = cvBase$ + "_v"

                if labelV$ = expectedV$

                    cBeg = Get start time of interval: tierNum, intNum
                    vEnd = Get end time of interval: tierNum, nextInt

                    cutStart = cBeg - leftMargin
                    cutEnd = vEnd + rightMargin


                    if cutEnd > cutStart

                        count = count + 1

                        cleanLabel$ = cvBase$
                        cleanLabel$ = replace$ (cleanLabel$, " ", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "/", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "\", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, ":", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "*", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "?", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, """", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "<", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, ">", "_", 0)
                        cleanLabel$ = replace$ (cleanLabel$, "|", "_", 0)

                        reptNum = 1
                        outBase$ = cleanLabel$ + "_rept" + string$ (reptNum)
                        outWav$ = outDir$ + outBase$ + ".wav"
                        outTg$ = outDir$ + outBase$ + ".TextGrid"

                        while fileReadable (outWav$) or fileReadable (outTg$)
                            reptNum = reptNum + 1
                            outBase$ = cleanLabel$ + "_rept" + string$ (reptNum)
                            outWav$ = outDir$ + outBase$ + ".wav"
                            outTg$ = outDir$ + outBase$ + ".TextGrid"
                        endwhile

                        selectObject: wav
                        wavNew = Extract part: cutStart, cutEnd, "rectangular", 1, "no"
                        selectObject: wavNew
                        Save as WAV file: outWav$

                        selectObject: tg
                        tgNew = Extract part: cutStart, cutEnd, "no"
                        selectObject: tgNew
                        Save as text file: outTg$

                        removeObject: tgNew
                        removeObject: wavNew


                    endif

                endif

            endif

        endif

    
    endfor


	removeObject: tg
  removeObject: wav


endfor

removeObject: wavList

writeInfoLine: "脚本成功运行 结果储存在", outPath$
