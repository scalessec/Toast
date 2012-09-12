using System;
using System.Drawing;

using MonoTouch.Foundation;
using MonoTouch.UIKit;
using System.Diagnostics;
using MonoTouch.ObjCRuntime;

namespace MonoTouch.Toast
{
	public static class ToastExtensions
	{
		public const float kMaxWidth = 0.8f;
		public const float kMaxHeight = 0.8f;
		public const float  kHorizontalPadding = 10.0f;
		public const float  kVerticalPadding = 10.0f;
		public const float  kCornerRadius = 10.0f;
		public const float  kOpacity = 0.8f;
		public const float  kFontSize = 16.0f;
		public const int  kMaxTitleLines = 999;
		public const int  kMaxMessageLines = 999;
		public const double  kFadeDuration = 0.2;
		public const bool  kDisplayShadow = true;
		public const double  kDefaultLength = 3.0;
		public const string kDefaultPosition = "bottom";
		public const float  kImageWidth = 80.0f;
		public const float  kImageHeight = 80.0f;
		public const float  kActivityWidth = 100.0f;
		public const float  kActivityHeight = 100.0f;
		public const string  kActivityDefaultPosition = "center";
		public const int  kActivityTag = 91325;

		public static void MakeToast (this UIView self,String message,double duration=kDefaultLength,string position=kActivityDefaultPosition,string title=null,UIImage image=null)
		{
			UIView toast = self.MakeViewForMessage(message,title,image);
			self.ShowToast(toast,duration,position);
		}

		public static void ShowToast(this UIView self,UIView toast,double interval=kDefaultLength,string position=kActivityDefaultPosition)
		{
			/****************************************************
		     *                                                  *
		     * Displays a view for a given duration & position. *
		     *                                                  *
		     ****************************************************/
			
			PointF toastPoint = self.GetPositionFor(position,toast);

			ToastAnimationHolder holder = new ToastAnimationHolder(interval);

			toast.Center = toastPoint;
			toast.Alpha = 0.0f;
			self.AddSubview(toast);

			UIView.BeginAnimations("fade_in",toast.Handle);
			UIView.SetAnimationDuration(kFadeDuration);
			UIView.SetAnimationDelegate(holder);
			UIView.SetAnimationDidStopSelector(new Selector("toastAnimationDidStop:finished:context:"));

			UIView.SetAnimationCurve(UIViewAnimationCurve.EaseOut);
			toast.Alpha=1.0f;
			UIView.CommitAnimations();
		}

		#region Toast Activity Methods

		public static void MakeToastActivity(this UIView self,string position=kActivityDefaultPosition)
		{
			// prevent more than one activity view
			UIView existingToast = self.ViewWithTag(kActivityTag);				
			if (existingToast != null) 
			{
				existingToast.RemoveFromSuperview();
			}
		
			UIView activityContainer = new UIView(CGRectMake(0, 0, kActivityWidth, kActivityHeight));
			activityContainer.Center = self.GetPositionFor(position,activityContainer);
			activityContainer.BackgroundColor = UIColor.Black.ColorWithAlpha(kOpacity);
			activityContainer.Alpha = 0.0f;
			activityContainer.Tag = kActivityTag;
			activityContainer.AutoresizingMask=(UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin);
			activityContainer.Layer.CornerRadius=kCornerRadius;
			if (kDisplayShadow) 
			{
				activityContainer.Layer.ShadowColor=UIColor.Black.CGColor;
				activityContainer.Layer.ShadowOpacity=0.8f;
				activityContainer.Layer.ShadowRadius=6.0f;
				activityContainer.Layer.ShadowOffset=CGSizeMake(4.0f, 4.0f);
			}
			
			UIActivityIndicatorView activityView = new UIActivityIndicatorView(UIActivityIndicatorViewStyle.WhiteLarge);
			activityView.Center=CGPointMake(activityContainer.Bounds.Size.Width / 2, activityContainer.Bounds.Size.Height / 2);
			activityContainer.AddSubview(activityView);
			activityView.StartAnimating();

			UIView.BeginAnimations(null);
			UIView.SetAnimationDuration(kFadeDuration);
			UIView.SetAnimationCurve(UIViewAnimationCurve.EaseOut);
			activityContainer.Alpha=1.0f;
			UIView.CommitAnimations();

			self.AddSubview(activityContainer);
		}

		public static void HideToastActivity(this UIView self)
		{
			UIView existingToast = self.ViewWithTag(kActivityTag);
			if (existingToast!=null)
			{
				UIView.BeginAnimations(null);
				UIView.SetAnimationDuration(kFadeDuration);
				UIView.SetAnimationDelegate(existingToast);
				UIView.SetAnimationDidStopSelector(new Selector("removeFromSuperview"));
				UIView.SetAnimationCurve(UIViewAnimationCurve.EaseIn);
				existingToast.Alpha=0.0f;
				UIView.CommitAnimations();
			}
		}

		#endregion

		#region Animation Delegate Method

		public class ToastAnimationHolder : NSObject
		{
			double interval;
			public ToastAnimationHolder(double interval_)
			{
				interval=interval_;
			}

			[Export("toastAnimationDidStop:finished:context:")]
			public void ToastAnimationDidStop(string animationID,bool finished,UIView toast)
			{
				if (animationID.Equals("fade_in"))
				{
					UIView.BeginAnimations("fade_out",toast.Handle);
					UIView.SetAnimationDelay(interval);
					UIView.SetAnimationDuration(kFadeDuration);
					UIView.SetAnimationDelegate(this);
					UIView.SetAnimationDidStopSelector(new Selector("toastAnimationDidStop:finished:context:"));
					UIView.SetAnimationCurve(UIViewAnimationCurve.EaseIn);
					toast.Alpha=0.0f;
					UIView.CommitAnimations();
				}
				else if (animationID.Equals("fade_out"))
				{
					toast.RemoveFromSuperview();
				}
			}
		}

		#endregion

		#region Private Methods
		
		private static PointF CGPointMake(float x,float y)
		{
			PointF p = new PointF(x,y);
			return p;
		}
		
		private static RectangleF CGRectMake(float x,float y,float width,float height)
		{
			RectangleF f = new RectangleF(x,y,width,height);
			return f;
		}
		
		private static SizeF CGSizeMake(float width,float height)
		{
			SizeF s = new SizeF(width,height);
			return s;
		}
		
		private static PointF GetPositionFor(this UIView self,string point,UIView toast)
		{
			/*************************************************************************************
		     *                                                                                   *
		     * Converts string literals @"top", @"bottom", @"center", or any point wrapped in an *
		     * NSValue object into a CGPoint                                                     *
		     *                                                                                   *
		     *************************************************************************************/
			
			string pointS = point.ToLower();
			
			if (pointS.Equals("top"))
			{
				return CGPointMake(self.Bounds.Size.Width/2, (toast.Frame.Size.Height / 2) + kVerticalPadding);
			}
			else if (pointS.Equals("bottom"))
			{
				return CGPointMake(self.Bounds.Size.Width/2, (self.Bounds.Size.Height - (toast.Frame.Size.Height / 2)) - kVerticalPadding);
			}
			else if (pointS.Equals("center") || pointS.Equals("centre"))
			{
				return CGPointMake(self.Bounds.Size.Width / 2, self.Bounds.Size.Height / 2);
			}
			else
			{
				// TODO: string to pointF
			}
			
			Debug.WriteLine("Error: Invalid position for toast.");
			return self.GetPositionFor(kDefaultPosition,toast);
		}
		
		#endregion

		public static UIView MakeViewForMessage(this UIView self,string message,string title,UIImage image)
		{
			
			/***********************************************************************************
		     *                                                                                 *
		     * Dynamically build a toast view with any combination of message, title, & image. *
		     *                                                                                 *
		     ***********************************************************************************/

			if((message == null) && (title == null) && (image == null)) return null;

			UILabel messageLabel = null;
			UILabel titleLabel = null;
			UIImageView imageView = null;

			// create the parent view
			UIView wrapperView = new UIView();
			wrapperView.AutoresizingMask=(UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin);
			wrapperView.Layer.CornerRadius=kCornerRadius;
			if (kDisplayShadow) 
			{
				wrapperView.Layer.ShadowColor=UIColor.Black.CGColor;
				wrapperView.Layer.ShadowOpacity=0.8f;
				wrapperView.Layer.ShadowRadius=6.0f;
				wrapperView.Layer.ShadowOffset=CGSizeMake(4.0f, 4.0f);
			}
			
			wrapperView.BackgroundColor=UIColor.Black.ColorWithAlpha(kOpacity);

			if(image != null) 
			{
				imageView = new UIImageView(image);
				imageView.ContentMode=UIViewContentMode.ScaleAspectFit;
				imageView.Frame=CGRectMake(kHorizontalPadding, kVerticalPadding, kImageWidth, kImageHeight);
			}
			
			float imageWidth, imageHeight, imageLeft;
			
			// the imageView frame values will be used to size & position the other views
			if(imageView != null) 
			{
				imageWidth = imageView.Bounds.Size.Width;
				imageHeight = imageView.Bounds.Size.Height;
				imageLeft = kHorizontalPadding;
			} 
			else 
			{
				imageWidth = imageHeight = imageLeft = 0.0f;
			}
			
			if (title != null) 
			{
				titleLabel = new UILabel();
				titleLabel.Lines = kMaxTitleLines;
				titleLabel.Font = UIFont.BoldSystemFontOfSize(kFontSize);
				titleLabel.TextAlignment=UITextAlignment.Left;
				titleLabel.LineBreakMode=UILineBreakMode.WordWrap;
				titleLabel.TextColor=UIColor.White;
				titleLabel.BackgroundColor=UIColor.Clear;
				titleLabel.Alpha=1.0f;
				titleLabel.Text=title;

				NSString titleS = new NSString(title);
				// size the title label according to the length of the text
				SizeF maxSizeTitle = CGSizeMake((self.Bounds.Size.Width * kMaxWidth) - imageWidth, self.Bounds.Size.Height * kMaxHeight);
				SizeF expectedSizeTitle = titleS.StringSize(titleLabel.Font,maxSizeTitle,titleLabel.LineBreakMode);
				titleLabel.Frame=CGRectMake(0.0f, 0.0f, expectedSizeTitle.Width, expectedSizeTitle.Height);
			}
			
			if (message != null) 
			{
				messageLabel = new UILabel();
				messageLabel.Lines=kMaxMessageLines;
				messageLabel.Font=UIFont.SystemFontOfSize(kFontSize);
				messageLabel.LineBreakMode=UILineBreakMode.WordWrap;
				messageLabel.TextColor=UIColor.White;
				messageLabel.BackgroundColor=UIColor.Clear;
				messageLabel.Alpha=1.0f;
				messageLabel.Text=message;
				
				// size the message label according to the length of the text
				NSString messageS = new NSString(message);
				SizeF maxSizeMessage = CGSizeMake((self.Bounds.Size.Width * kMaxWidth) - imageWidth, self.Bounds.Size.Height * kMaxHeight);
				SizeF expectedSizeMessage = messageS.StringSize(messageLabel.Font,maxSizeMessage,messageLabel.LineBreakMode);
				messageLabel.Frame=CGRectMake(0.0f, 0.0f, expectedSizeMessage.Width, expectedSizeMessage.Height);
			}
			
			// titleLabel frame values
			float titleWidth, titleHeight, titleTop, titleLeft;
			
			if(titleLabel != null) 
			{
				titleWidth = titleLabel.Bounds.Size.Width;
				titleHeight = titleLabel.Bounds.Size.Height;
				titleTop = kVerticalPadding;
				titleLeft = imageLeft + imageWidth + kHorizontalPadding;
			}
			else 
			{
				titleWidth = titleHeight = titleTop = titleLeft = 0.0f;
			}
			
			// messageLabel frame values
			float messageWidth, messageHeight, messageLeft, messageTop;
			
			if(messageLabel != null) 
			{
				messageWidth = messageLabel.Bounds.Size.Width;
				messageHeight = messageLabel.Bounds.Size.Height;
				messageLeft = imageLeft + imageWidth + kHorizontalPadding;
				messageTop = titleTop + titleHeight + kVerticalPadding;
			}
			else 
			{
				messageWidth = messageHeight = messageLeft = messageTop = 0.0f;
			}			

			float longerWidth = Math.Max(titleWidth, messageWidth);
			float longerLeft = Math.Max(titleLeft, messageLeft);
			
			// wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
			float wrapperWidth = Math.Max((imageWidth + (kHorizontalPadding * 2)), (longerLeft + longerWidth + kHorizontalPadding));    
			float wrapperHeight = Math.Max((messageTop + messageHeight + kVerticalPadding), (imageHeight + (kVerticalPadding * 2)));
			
			wrapperView.Frame=CGRectMake(0.0f, 0.0f, wrapperWidth, wrapperHeight);
			
			if(titleLabel != null) 
			{
				titleLabel.Frame=CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
				wrapperView.AddSubview(titleLabel);
			}
			
			if(messageLabel != null) 
			{
				messageLabel.Frame=CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
				wrapperView.AddSubview(messageLabel);
			}
			
			if(imageView != null) 
			{
				wrapperView.AddSubview(imageView);
			}
			
			return wrapperView;
		}
		
	
		




	}
}
