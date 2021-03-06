lik_Bayesian<-function (Data, Beta,print,  initialQ){
  # This function computes the likelihood of the participants'
  # choices conditional on the Rescorla Wagner model, incorporating the belief about the change point
  #
  # Input
  #   Data: a long dataset where each row represents a trial. 
  #   beta: a candidate beta parameter
  #   print: 1: return only the negative log-likelihood; 
  #          2: return 1: "Negative LogLikel"; 2:"Q1"; 3:"Q2"; 4:"Q3"
  #          5: "Delta1"; 6: "Delta2"; 7: "Delta3", 8: "P1" (Probability
  #           of choosing category 1), 9:"P2", 10: "P3"
  #   initialQ: value of the inital Q
  #
  # Output:
  #   Negative Log Likelihood
  # -------------
  
  # convert the resp flower into numeric variable
  levels(Data$respFlower)
  
  #1 "blue_flower"  2  "green_flower" 3 "red_flower"  4  "yellow_flower"
  Data$FlowNum<-as.numeric((Data$respFlower))
  
  Data$corrFlower<-as.numeric((Data$corrFlower))
  
  # Initialize variables: Qs, the expected values
  Data$Q1<-NA; Data$Q2<-NA; Data$Q3<-NA ; Data$Q4<-NA 
  
  # Ps (probabilities for each flower's choice)
  Data$Qup1<-NA; Data$Qup2<-NA; Data$Qup3<-NA ; Data$Qup4<-NA
  
  Data$N1<-NA; Data$N2<-NA; Data$N3<-NA ; Data$N4<-NA
  
  Data$Delta1<-NA; Data$Delta2<-NA; Data$Delta3<-NA; Data$Delta4<-NA;
  
  # probability for the choice that participants' made on a trial
  Data$Prob<-NA
  
  # Delta, prediction error
  Delta<-c("Delta1", "Delta2", "Delta3", "Delta4")
  
  # uncertainty as the 1/variance of the probability
  Data$uncertainty<-NA
  
  # change point probability
  Data$CPP<-NA
  
  # probability of change point not occurring
  Data$CPnot<-NA
  
  # true probability of a change point - 3 changepoints divided by the number of the trials
  CPtrue<-3/nrow(Data)
  
  # learning rate
  Data$lr<-NA
  
  # initialize alpha and beta
  alpha<-1
  beta<-1
  
  # index variables for Q, P, Delta, and N
  Qindex<-c("Q1", "Q2", "Q3", "Q4")
  Qupindex<-c("Qup1", "Qup2", "Qup3", "Qup4") 
  Deltaindex<-c("Delta1", "Delta2", "Delta3", "Delta4")
  
  # N is the sum about CP occurring when the same option was chosen (same flower)
  N<-c("N1", "N2", "N3", "N4")
  
  # Counter for indicating which butterfly has to be updated
  count<-rep(0, 2)
  
  # convert butterfly as numeric
  Data$butterfly<-as.character(Data$butterfly)
  for (t in 1:nrow(Data)){
    if(Data$butterfly[t]=="white_butterfly"){
      Data$butterfly[t]<-1
    }else{Data$butterfly[t]<-2}
  }
  Data$butterfly<-as.numeric(Data$butterfly)
  
  # initialise choice probability and counter for the choiceprobability
  prob<-NA
  count2<-1
  
  # loop over trials and depending on the flower that is correct create a 
  # array with 1 for the flower where the butterfly is going to, and 0 for the 
  # rest of the flowers. We will use this variable for PE calculation
  for (t in 1: nrow(Data)){
    
    if (Data$corrFlower[t]==1){
      obs<-c(1,0,0,0)
    } else if (Data$corrFlower[t]==2){
      obs<-c(0,1,0,0)
    } else if (Data$corrFlower[t]==3){
      obs<-c(0,0,1,0)
    }else if (Data$corrFlower[t]==4){
      obs<-c(0,0,0,1)
    }
    
    
    # The following loop retrieves the Q values of the butterfly that corresponds to the current trial (time t).
    if (count[Data$butterfly[t]]==0){ # if it is the first time that participants are seeing that butterfly
      
      Data[t, Qindex]<-rep(0, 4)+(alpha/(alpha+beta+alpha+beta)) # initialize the Qs at 0.25
      
      Data[t,N]<-rep(alpha+beta, 4) # initialize the Ns at 2
      
      count[Data$butterfly[t]]<-count[Data$butterfly[t]]+1 # update the counter
      
    } else{ # if this is not the first time participants are seeing that butterfly
      
      # retrieve the Qs and Ns from the last time participants saw the same butterfly
      Data[t, Qindex]<-Data[Data$butterfly==Data$butterfly[t],][count[Data$butterfly[t]],Qupindex]
      
      Data[t, N]<-unlist(Data[Data$butterfly==Data$butterfly[t],][count[Data$butterfly[t]], N])
      
      count[Data$butterfly[t]]<-count[Data$butterfly[t]]+1 # update the counter
    }
    
    # update choice probabilities using the softmax distribution
    p<-softmax(Data[t, Qindex], Beta)
    
    # compute Q, delta, and choice probability for actual choice, only if a choice was made
    if (Data$response[t]!=0 & !is.na(Data$FlowNum[t]) ){
      
      # probability only for the response made by participant
      prob[count2]<-unlist(p[Data$FlowNum[t]])
      
      # assign it to the dataset
      Data$Prob[t]<- prob[count2]
      
      # update the counter 
      count2<-count2+1
      
      # change point probability
      if (Data$accuracy[t]==1){ # if the accuracy was correct
        
        # what is the probability of CP not occurring given that feedback is 1 - see "BayesianModelPresentation.odp"
        Data$CPnot[t]<-(Data$Prob[t]*(1-CPtrue))/(Data$Prob[t]*(1-CPtrue)+CPtrue/3)
        
      } else {
        
        # what is the probability of CP not occurring given that feedback is 0
        Data$CPnot[t]<-((1-Data$Prob[t])*(1-CPtrue))/((1-Data$Prob[t])*(1-CPtrue)+(CPtrue/3))
        
      }
      
    } else { # if a choice was not made
      
      # retrieve the choice probability from the last trial of that butterfly
      Data$Prob[t]<-Data[Data$butterfly==Data$butterfly[t],][count[Data$butterfly[t]]-1,"Prob"]
      
      # calculate the probability of CP not occurring given that the  and is considered incorrect
      Data$CPnot[t]<-((1-Data$Prob[t])*(1-CPtrue))/((1-Data$Prob[t])*(1-CPtrue)+(CPtrue/3))
      
    }
    
    # N is the belief that there wasn't a change point up to this trial for that choice
    # we need to take the n referred to the choice
    Nchoice<-paste("N", Data$corrFlower[t], sep="")
    
    # learning rate
    Data$lr[t]<-Data$CPnot[t]/(Data[t, Nchoice]+alpha+beta)
    
    # prediction error
    Data[t, Delta]<- obs - Data[t, Qindex]
    
    # update - rescorla wagner formula multiplied by probability of change point
    Data[t, Qupindex]<-as.numeric(Data[t, Qindex]+Data$lr[t]*Data[t, Delta]*Data$CPnot[t])
    
    # update N
    Data[t, Nchoice]<-Data[t, Nchoice]+Data$CPnot[t]
    
    # compute uncertainty as the 1/variance of the probability
    uncertainty<-1/(var(unlist(Data[t, Qupindex]))+1)
    
    # uncertainty as the -log(sum prob * log prob)
    #uncertainty2<- -sum(  unlist(Data[t,Qupindex]) *log(unlist(Data[t,Qupindex])))
    
    # change point probability
    Data$CPP[t]<- 1-Data$CPnot[t]
    
    # probability of that observations
    # probobs<-Data[t, paste("P", Data$FlowNum[t], sep="")]
    
    if (count[Data$butterfly[t]]==1 |count[-Data$butterfly[t]]==0 ){ # while one of the two butterlfy has not been shown
      
      Data$uncertainty[t]<-uncertainty
      #Data$uncertainty2[t]<-uncertainty2
      #Data$CPP[t]<-probobs
      # uncertainty as the -log(sum prob * log prob)
      
    } else{
      
      # retrieve uncertainty on the last trial of the other butterfly
      unctmin1<-Data[Data$butterfly!=Data$butterfly[t],][count[-Data$butterfly[t]], "uncertainty"]
      
      #unc2tmin1<-Data[Data$butterfly!=Data$butterfly[t],][count[-Data$butterfly[t]], "uncertainty2"]
      
      # retrieve probability of the observation on the previous trial for the same butterfly
      #probobstminus1<-Data[Data$butterfly==Data$butterfly[t],][count[Data$butterfly[t]]-1,paste("P", Data$FlowNum[t], sep="") ]
      
      # average the two "uncertainties"
      Data$uncertainty[t]<-mean(uncertainty,unctmin1)
      # Data$uncertainty2[t]<-mean(uncertainty2,unctmin1)
      # Data$CPP[t]<-probobs*probobstminus1
      
      
    }
  }
  
  # we could take the probability only for the congruent trials, but for now we are taking all the probabilities
  NegLL<--sum(log(Data$Prob), na.rm=T)
  
  if (print ==1){
    return(NegLL)
  }else if ( print==2){
    return (list("Negative LogLikel"=NegLL, "Q1"= Data$Q1,"Q2"= Data$Q2,"Q3"= Data$Q3,"Q4"= Data$Q4,
                 "Delta1"= Data$Delta1, "Delta2"= Data$Delta2,"Delta3"= Data$Delta3, "Delta4"= Data$Delta4
    ))
  } else if(print==3){
    return(Data)}
}

