python3 imgConvert.py
nasm -f elf64 main.asm -o main.o
ld main.o -o main
./main
python3 img.py
