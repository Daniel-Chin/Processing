int N = round(pow(5, 3));
int MOD = 5;

size(600, 600);

int[] row = new int[N];
row[0] = 1;
int[] next_row;
for (int i = 0; i < N; i ++) {
  next_row = new int[N];
  for (int j = 0; j < N; j ++) {
    stroke(row[j] * 255 / (MOD - 1));
    point(j, i);
    if (i != N - 1) {
      if (j == 0) {
        next_row[j] = 1;
      } else {
        next_row[j] = (row[j - 1] + row[j]) % MOD;
      }
    }
    //print(next_row[j]);
  }
  //println();
  row = next_row;
}
