NAME = ../McScatter

BSE.exe = $(NAME)_BSE
SeBa.exe = $(NAME)_SeBa

BSE : 
	($(BSE.exe) < example.in > example_BSE.out )>& example_BSE.log 

SeBa : 
	($(SeBa.exe) < example.in > example_SeBa.out )>& example_SeBa.log 

clean:
	rm -f *.o *.log *.out *.data
