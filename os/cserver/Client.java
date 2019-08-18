import java.io.*;
import java.net.*;

class Client {
	public static void main(String[] args) {
		try {
			int i,od;
            i = od = 0;
			long[][] j = new long[500000][2];

			Socket s=null;
			s = new Socket(args[0], Integer.parseInt(args[1]));
			BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));

			while (true) {
                if(br.ready()){
                    j[i][0] = Integer.parseInt(br.readLine());
                    j[i][1] = System.currentTimeMillis();//60000 milis = 1 min
                    i++;
                }
                long buck =  System.currentTimeMillis();//THE BUCK STOPS HERE
                int m = 0;
                //check for out of dates here
                for(int k = od;k<i;k++){
                    if((buck-j[k][1]) > 60000 ){
                        od++;
                    }
                    else{
                        m += j[k][0];
                    }
                }
				if((i-od) == 0){System.out.println("Mean is " + 0);}
                else {System.out.println("Mean is" + (float)m/(i-od));}
                /*
				if(i>=10){
					int x = 0;
					j[ch] = Integer.parseInt(br.readLine());
					for(int ss = 0;ss<10;ss++){
						x+= j[ss];
					}
					x/=10;
					System.out.println(x);

					ch++;
					if(ch>=10){
						ch = 0;
					}
				}
				else{
					j[i] = Integer.parseInt(br.readLine());
					System.out.println(j[i]);
					i++;
				}
                */
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

    public void mean(int i,int x){

    }
}
